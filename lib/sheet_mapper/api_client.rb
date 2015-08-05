module SheetMapper
  class ApiClient
    KEY_PASSWORD = 'notasecret'
    REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob"
    SCOPE = [
      "https://www.googleapis.com/auth/drive",
      "https://spreadsheets.google.com/feeds/"
    ]
    TOKEN_CREDENTIAL_URI = 'https://accounts.google.com/o/oauth2/token'
    class LoginFailure < StandardError; end

    def initialize(options = {})
      options[:app_name] ||= 'SheetMapper'
      options[:app_version] ||= SheetMapper::VERSION
      @app_name, @app_version = options[:app_name], options[:app_version]
    end

    def authorization_uri
      @authorization_client.authorization_uri
    end

    def native_login(client_id, client_secret, refresh_token = nil)
      @authorization_client = native_auth_client(client_id, client_secret)
      if refresh_token
        print "\nAttempting to reuse previously saved session..."
        @authorization_client.refresh_token = refresh_token
      else
        @authorization_client.code = prompt_for_auth_code
      end
      begin
        @authorization_client.fetch_access_token!
      rescue Signet::AuthorizationError
        raise unless refresh_token
        print "  Failed!\n"
        native_login(client_id, client_secret)
      else
        print "  Success!\n" if refresh_token
      end
    end

    def refresh_token
      @authorization_client.refresh_token
    end

    def service_login(client_id, client_email, p12_path)
      key = Google::APIClient::KeyUtils.load_from_pkcs12(p12_path, KEY_PASSWORD)
      @authorization_client = service_auth_client(client_email, key)
      @authorization_client.fetch_access_token!
    end

    def session
      @session ||= begin
        fail LoginFailure, "You must execute a login method" if @authorization_client.nil?
        @session = GoogleDrive.login_with_oauth(@authorization_client.access_token)
      end
    end

    private

    def native_auth_client(client_id, client_secret)
      client = Google::APIClient.new(application_name: @app_name, application_version: @app_version)
      auth = client.authorization
      auth.client_id = client_id
      auth.client_secret = client_secret
      auth.redirect_uri = REDIRECT_URI
      auth.scope = SCOPE
      auth
    end

    def prompt_for_auth_code
      print "\n"
      print("1. Open your favorite web browser\n")
      print("2. Sign in to your Google account\n")
      print("3. Open the following URL:\n\n%s\n\n" % authorization_uri)
      print("4. Click \"Accept\" to grant this application access to your Google Drive\n")
      print("5. Enter the authorization code shown in the page: ")
      STDIN.gets.chomp
    end

    def service_auth_client(client_email, key)
      Signet::OAuth2::Client.new(
        token_credential_uri: TOKEN_CREDENTIAL_URI,
        audience: TOKEN_CREDENTIAL_URI,
        scope: SCOPE,
        issuer: client_email,
        access_type: 'offline',
        signing_key: key
      )
    end
  end
end