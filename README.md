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
class BubbleMapper < SheetMapper::Base
  # Defines each column for a row and maps each column to an attribute
  columns :offset_seconds, :is_notable, :category, :body, :image_url, :link_text, :link_url

  # Defines the condition for a row to be considered valid
  def valid_row?
    self[:body].present? && @pos > 7
  end

  # Convert is_notable column to a boolean from raw string
  # Any methods named after a column will override the default value
  def is_notable
    !!self[:is_notable].match(/true/i)
  end
end
```

This describes the column mappings and transformations to turn a spreadsheet row into a ruby object. Then you can use
a mapper within a worksheet collection:

```ruby
sheet = SheetMapper::Worksheet.new(:mapper => BubbleMapper, :key => 'sheet_key', :login => 'user', :password => 'pass')
collection = sheet.find_collection_by_title('title')
bubbles = collection.each do |bubble|
  p bubble.attributes
  # => { :offset_seconds => "...", :is_notable => false, ... }
end
```

You can then work with the objects within the collection and access their attributes.

## Contributors

SheetMapper was created by [Nathan Esquenazi](http://github.com/nesquena) at Miso in 2012.