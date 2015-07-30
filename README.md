# SheetMapper

SheetMapper is about taking a google spreadsheet and converting a set of data rows into simple ruby objects.

## Installation

Setup in Gemfile:

```ruby
# Gemfile

gem 'sheet_mapper'
```

and then `require 'sheet_mapper'` and you are done!

## Rationale

You may ask why you would need to have an object mapper from a Google Spreadsheet. Consider though that spreadsheets are collaborative, have revision tracking, securely authenticated, are accessible anywhere and are familiar to non-technical people. 

If you ever needed a dead simple admin interface, configuration document, or basic content management system, a spreadsheet is a pretty great solution that requires very little engineering overhead. Next time you are in a position where non-technical people
need to manage data, ask yourself if a spreadsheet might be a good first solution.

## Usage

First, you describe how to map a spreadsheet into data rows with a sheet object mapper:

```ruby
class SomeMapper < SheetMapper::Base
  # Defines each column for a row and maps each column to an attribute
  # Should be listed in the order the data appears in the spreadsheet
  columns :foo, :bar, :baz

  # Defines the condition for a row to be considered valid
  # Also have access to `pos` which is the row number in the worksheet
  def valid_row?
    self[:foo].present? && self.pos > 2
  end

  # Convert bar column to a boolean from raw string
  # Any method named after a column will override the default value
  def bar
    !!self[:bar].match(/true/i)
  end
end
```

The mapper describes the column mappings and transformations to turn a spreadsheet row into a ruby object. Then you can apply
a mapper to any worksheet (collection):

```ruby
# Access a particular spreadsheet by key
sheet = SheetMapper::Spreadsheet.new(:mapper=>SomeMapper, :key=>'k', :session => YourGoogleSession)
# Find a particular worksheet (collection) by title
collection = sheet.find_collection_by_title('title')
# Iterate over the records within the worksheet
records = collection.each do |record|
  p record.attributes
  # => { :foo => "...", :bar => false, ... }
end
```

You can then work with objects within the collection and access their attributes. You can also modify objects and
persist the changes back to the collection (worksheet):

```ruby
# Fetch the second data row from the spreadsheet
record = collection.records[1]
record[:foo] = "other"
# Persist change of value to worksheet
collection.save
# or more explicitly collection.save(record)
```

If you want to reset changes made to your records, just use the reload method:

```ruby
# Fetch the second data row from the spreadsheet
record = collection.records[1]
record[:foo] = "other"
# Reset unsaved changes
collection.reload
```

You may also come across situations where you need access to 'meta' information associated with the collection.
Use the 'cell' method to access arbitrary data points:

```ruby
# Accesses row 1, column 2 within the worksheet
collection.cell(1, 2) => "foo"
```

## Setting up OAuth 2.0

To start, [follow the instructions](https://developers.google.com/console/help/new/?hl=en_US#setting-up-oauth-20) provided by Google for enabling OAuth 2.0 integration with your Google Drive account.

#### Service account, Web application, or installed application?

If you are building an application that integrates with a known set of
documents, it is recommended to create your Oauth credentials as a "Service
account". This will generate a re-usable [PKCS key](https://en.wikipedia.org/wiki/PKCS_12).
That means that once you authenticate the first time, no further action will be
required on your part to maintain secure integration with Google.

You can also choose the "installed application" (aka native application)
credentials, but this requires that you access a specially crafted URL and enter
in a authentication code each time your session times out. If you are building
a CLI tool, this becomes tedious. If you are building a customer-facing
application, it adds friction to the process.

If you are building a web application that provides integration to your
*customers* Google Drive, that is, unfortunately, not yet supported.

### Authenticating with Google Drive

#### Service Account

First, make note of the Client ID and Email address (service address) that
Google's OAuth Credentials generates for you. You can find these values under
the "APIs & auth -> Credentials" menu of the Google Developers Console which can
be reached at https://console.developers.google.com/project/[YOUR-APPLICATION-NAME]/apiui/credential

Second, store your PKCS key somewhere on your server that is secure and
accessible to your application's Ruby process. Make note of that path.

In your application code:

```ruby
google_api = SheetMapper::ApiClient.new
google_api.service_login(YOUR_CLIENT_ID, YOUR_SERVICE_ADDRESS, PATH_TO_YOUR_PKCS_KEY)
```

#### Installed/Native Application

First, make note of the Client ID and Client secret that Google's OAuth
Credentials generates for you. You can find these values under the
"APIs & auth -> Credentials" menu of the Google Developers Console which can be
reached at https://console.developers.google.com/project/[YOUR-APPLICATION-NAME]/apiui/credential

In your application code:

```ruby
google_api = SheetMapper::ApiClient.new
google_api.native_login(YOUR_OAUTH_ID, YOUR_CLIENT_SECRET)
```

Calling `SheetMapper::ApiClient#native_login` will prompt you via `STDIN` to
open a specific URL and to enter the Auth Code that Google generates for you.

This will authenticate your application for the life of the current session.

##### Re-using an Installed/Native Application OAuth Session

Once successfully authentication. you can re-use an OAuth session by persisting
your session's Refresh Token somewhere like the file system or in your database:

```ruby
open(PATH_TO_REFRESH_TOKEN, 'w', 0600) do |f|
  f.puts(google_api.refresh_token)
end
```

Then, when requesting access to your Google Drive account in a new session:

```ruby
cached_refresh_token = File.open(PATH_TO_REFRESH_TOKEN, &:gets).chomp if File.exists?(PATH_TO_REFRESH_TOKEN)
google_api = SheetMapper::ApiClient.new
google_api.native_login(YOUR_OAUTH_ID, YOUR_CLIENT_SECRET, YOUR_REFRESH_TOKEN, cached_refresh_token)
```

Google indicates that the refresh token is good for 1-hour. If the token is
fresh, then no prompt will be issued to open a URL or enter in any additional
information.

If the token is stale, you will be prompted to re-authenticate your application
by opening the URL and entering in a new authentication code.

#### Web Application

Unfortunately, this method of OAuth authentication is not yet supported.

### Accessing Your Sheets

Once you have a successfully authentication Google Drive session, you can access
your sheets by passing your session into SheetMapper:

```ruby
sheet = SheetMapper::Spreadsheet.new(
  mapper: SomeMapper,
  key: SpreadsheetKey,
  session: google_api.session
)
sheet.find_collection_by_title('worksheet title')
```

## Contributors

SheetMapper was created by [Nathan Esquenazi](http://github.com/nesquena) at Miso in 2012. The following users
contributed to the project:

 * [Derek Lindahl](https://github.com/dlindahl) - Added simple delegation to collections

## Tasks

SheetMapper is a new gem and I would love any feedback and/or pull requests. In particular:

 * Inserting a data row into a collection
 * Removing a data row from a collection
 * Callbacks
 * Validations
 * Column Type Casting

Please fork if you are inspired to add any of these or any other improvements.

## Continuous Integration ##

[![Continuous Integration status](https://secure.travis-ci.org/nesquena/sheet_mapper.png)](http://travis-ci.org/nesquena/sheet_mapper)

CI is hosted by [travis-ci.org](http://travis-ci.org).

## License

Check `LICENSE` but of course feel free to use this in any projects.