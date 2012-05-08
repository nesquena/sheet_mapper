# SheetMapper

Define a mapper:

```ruby
class BubbleMapper < SheetMapper::Base
  columns :offset_seconds, :is_notable, :category, :body, :image_url, :link_text, :link_url

  def valid_row?
    self[:body].present? && @pos > 7
  end

  # Convert is_notable to boolean
  def is_notable
    self[:is_notable].to_s.match(/true/i).present?
  end
end
```

Use a mapper:

```ruby
sheet = SheetMapper::Worksheet.new(:mapper => BubbleMapper, :key => 'sheet_key', :login => 'user', :password => 'pass')
collection = sheet.find_collection_by_title('title')
bubbles = collection.each do |bubble|
  p bubble.to_hash
end
```