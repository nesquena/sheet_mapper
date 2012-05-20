module SheetMapper
  class Base

    attr_reader :pos

    # SheetMapper::Base.new(1, ["foo", "bar"])
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

    # Returns an array of data values based on the order of the spreadsheet
    # @record.to_a => ["Foo", "Bar", 15]
    def attribute_values
      self.column_order.inject([]) { |res, name| res << @attrs[name]; res }
    end

    # Returns true if a record has been modified from original state
    # @record.changed? => true
    def changed?
      @data != self.attribute_values
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
      column_order.each { |name| m[name.to_s] = self.fetch_data_value(name) }
      m
    end

    # fetch_data_value(:body) => "Foo"
    # fetch_data_value(:image_url) => nil
    # fetch_data_value(:link_text) => "Article"
    # Column position is found by matching named column in `column_order`
    def fetch_data_value(name)
      val = @data[column_pos(name)]
      val = val.to_i if val && name.to_s =~ /_(id|num)/
      val
    end

  end
end