require File.expand_path('../test_config.rb', __FILE__)

describe "ApiClient" do
  setup do
    @client = SheetMapper::ApiClient.new
  end

  context "#native_login" do
    setup do
      @fake_client = mock('fake_native_client')
      @client.stubs(:native_auth_client).returns(@fake_client)
    end

    it "fetches the access token from a user-entered auth code" do
      client_id = "YOUR CLIENT ID"
      client_secret = "YOUR CLIENT SECRET"
      @client.stubs(:prompt_for_auth_code).returns('AUTH_CODE')
      @fake_client.expects('code=').returns('AUTH_CODE')
      @fake_client.expects('fetch_access_token!')
      @client.native_login(client_id, client_secret)
    end

    context "with a fresh refresh token" do
      it "reuses the previous session" do
        client_id = "YOUR CLIENT ID"
        client_secret = "YOUR CLIENT SECRET"
        refresh_token = "YOUR REFRESH TOKEN"
        @fake_client.expects('refresh_token=').returns(refresh_token)
        @fake_client.expects('fetch_access_token!')
        @client.expects(:print).at_least_once
        @client.native_login(client_id, client_secret, refresh_token)
      end
    end
  end

  context "#service_login" do
    setup do
      @fake_client = mock('fake_native_client')
      @client.stubs(:service_auth_client).returns(@fake_client)
    end

    it "uses the P12 key to fetch the access token" do
      client_id = "YOUR CLIENT ID"
      client_email = "client@example.com"
      key_path = "PATH_TO_KEY"
      Google::APIClient::KeyUtils.expects(:load_from_pkcs12).with(key_path, 'notasecret').returns('KEY')
      @fake_client.expects('fetch_access_token!')
      @client.service_login(client_id, client_email, key_path)
    end
  end

  context "#session" do
    context "without being logged in" do
      it "raises an error" do
        assert_raises SheetMapper::ApiClient::LoginFailure do
          @client.session
        end
      end
    end

    context "with a logged in session" do
      setup do
        @fake_client = mock('fake_client', access_token:'ACCESS_TOKEN')
        @client.instance_variable_set('@authorization_client', @fake_client)
      end

      it "returns a GoogleDrive API instance" do
        @google_api = mock('google_api')
        GoogleDrive.expects(:login_with_oauth).with('ACCESS_TOKEN').returns(@google_api)
        assert_equal @google_api, @client.session
      end
    end
  end

  # context "authorization" do
  #   should "return a OAuth2 Client" do
  #     assert_kind_of Signet::OAuth2::Client, @client.authorization
  #   end
  # end

  # context "session" do
  #   setup do
  #     @client.expects(:get_token!).returns(123)
  #   end

  #   should "returns a GoogleDrive::Session" do
  #     assert_kind_of GoogleDrive::Session, @client.session
  #   end
  # end

  # context "prompt_for_auth_code" do
  #   setup do
  #     @client.expects(:print).twice
  #     STDIN.expects(:gets).returns('AUTH_CODE')
  #   end

  #   should "prompt the user to enter a code retrieved from a URI" do
  #     assert_equal 'AUTH_CODE', @client.prompt_for_auth_code
  #   end
  # end
end
