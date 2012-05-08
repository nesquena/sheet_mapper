# SheetMapper

SheetMapper is about taking a google spreadsheet and converting a set of data rows into ruby objects.

## Usage

Define an object mapper:

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

Use a mapper:

```ruby
sheet = SheetMapper::Worksheet.new(:mapper => BubbleMapper, :key => 'sheet_key', :login => 'user', :password => 'pass')
collection = sheet.find_collection_by_title('title')
bubbles = collection.each do |bubble|
  p bubble.attributes
  # => { :offset_seconds => "...", :is_notable => false, ... }
end
```

You can then use these collections of objects and transform them into any format as needed.