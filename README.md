# SheetMapper

SheetMapper is about taking a google spreadsheet and converting a set of data rows into ruby objects.

## Installation

Setup in Gemfile:

```ruby
# Gemfile

gem 'sheet_mapper'
```

and then `require 'sheet_mapper'` and you are done!

## Usage

First, define yourself an object mapper:

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

This describes the column mappings and transformations to turn a spreadsheet row into a ruby object. Then you can use
a mapper within a worksheet collection:

```ruby
sheet = SheetMapper::Worksheet.new(:mapper => SomeMapper, :key => 'k', :login => 'u', :password => 'p')
collection = sheet.find_collection_by_title('title')
records = collection.each do |record|
  p record.attributes
  # => { :foo => "...", :bar => false, ... }
end
```

You can then work with the objects within the collection and access their attributes.

## Contributors

SheetMapper was created by [Nathan Esquenazi](http://github.com/nesquena) at Miso in 2012.