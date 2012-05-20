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
  columns :foo, :bar, :baz

  # Defines the condition for a row to be considered valid
  def valid_row?
    self[:foo].present?
  end

  # Convert is_notable column to a boolean from raw string
  # Any methods named after a column will override the default value
  def is_notable
    !!self[:bar].match(/true/i)
  end
end
```

The mapper describes the column mappings and transformations to turn a spreadsheet row into a ruby object. Then you can apply
a mapper to any worksheet (collection):

```ruby
# Login and access a particular spreadsheet by key
sheet = SheetMapper::Spreadsheet.new(:mapper=>SomeMapper, :key=>'k', :login => 'u', :password => 'p')
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

## Contributors

SheetMapper was created by [Nathan Esquenazi](http://github.com/nesquena) at Miso in 2012.

## Tasks

SheetMapper is a new gem and I would love any feedback and/or pull requests.

## Continuous Integration ##

[![Continuous Integration status](https://secure.travis-ci.org/nesquena/sheet_mapper.png)](http://travis-ci.org/nesquena/sheet_mapper)

CI is hosted by [travis-ci.org](http://travis-ci.org).

## License

Check `LICENSE` but of course feel free to use this in any projects.