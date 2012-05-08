module SheetMapper
  class Base

    # SheetMapper::Base.new(0, ["foo", "bar"])
    def initialize(pos, data=[])
      @pos    = pos
      @data   = data
      @attrs  = process_data
    end

    # columns :offset_seconds, :body, :link_url, :category
    def self.columns(*names)
      names.any? ? @columns = names : @columns
    end

    # Returns the spreadsheet as a hash
    def attributes
      result = HashWithIndifferentAccess.new
      @attrs.each do |name, val|
        result[name] = self.respond_to?(name) ? self.send(name) : val
      end
      result
    end

    # Returns an attribute value
    # @record[:attr_name]
    def [](name)
      @attrs[name]
    end

    # Assign an attribute value
    # @record[:attr_name]
    def []=(name, val)
      @attrs[name] = val
    end

    # Returns true if the row is a valid record
    def valid_row?
      true
    end

    protected

    # column_order => [:offset_seconds, :body, :link_url, :category]
    def column_order
      self.class.columns
    end

    # column_pos(:offset_seconds) => 1
    # column_pos(:body) => 4
    def column_pos(name)
      self.column_order.index(name)
    end

    def log(text, newline=true)
      output = newline ? method(:puts) : method(:print)
      output.call(text) if LOG
    end # log

    # Process all columns into an attribute hash
    def process_data
      m = HashWithIndifferentAccess.new
      column_order.each { |name| m[name.to_s] = self.attribute_value(name) }
      m
    end

    # attribute_value(:body, 1, 1) => "Foo"
    # attribute_value(:image_url, 1, 3) => nil
    # attribute_value(:link_text, 2) => "Article"
    # Create a method "format_<name>" to transform the column value (or pass the value directly)
    # Column position defaults to matching named column in `column_order`
    def attribute_value(name)
      val = @data[column_pos(name)]
      val = val.to_i if val && name.to_s =~ /_(id|num)/
      val
    end

  end
end