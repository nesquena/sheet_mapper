module SheetMapper
  class Spreadsheet
    attr_reader :mapper, :session, :spreadsheet

    # SheetMapper::Worksheet.new(:mapper => SomeMapper, :key => 'sheet_key', :login => 'user', :password => 'pass')
    def initialize(options={})
      @mapper = options[:mapper]
      @session = options[:session]
      @spreadsheet = find_spreadsheet(options[:key], options[:url], options[:title])
    end

    # Returns the first worksheet with given title
    # sheet.find_collection_by_title('title') => <SheetMapper::Collection>
    def find_collection_by_title(val)
      val_pattern = /#{val.to_s.downcase.gsub(/\s/, '')}/
      worksheet = self.spreadsheet.worksheets.find { |w| w.title.downcase.gsub(/\s/, '') =~ val_pattern }
      raise CollectionNotFound, "No worksheet found '#{val}'! Please try again." unless worksheet
      Collection.new(self, worksheet)
    end

    private
    def find_spreadsheet(key, url, title)
      raise ArgumentError, "No key, url or title specified for the spreadsheet" unless key || url || title
      return @session.spreadsheet_by_url(url) if url
      return @session.spreadsheet_by_title(title) if title
      @session.spreadsheet_by_key(key)
    end

  end
end