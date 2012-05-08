module SheetMapper
  class Spreadsheet
    attr_reader :mapper, :session, :spreadsheet

    # SheetMapper::Worksheet.new(:mapper => BubbleMapper, :key => 'sheet_key', :login => 'user', :password => 'pass')
    def initialize(options={})
      @mapper   = options[:mapper]
      @session = ::GoogleSpreadsheet.login(options[:login], options[:password])
      @spreadsheet = @session.spreadsheet_by_key(options[:key])
    end

    # sheet.find_collection_by_title('title')
    def find_collection_by_title(val)
      val_pattern = /#{val.to_s.downcase.gsub(/\s/, '')}/
      worksheet = self.spreadsheet.worksheets.find { |w| w.title.downcase.gsub(/\s/, '') =~ val_pattern }
      Collection.new(self, worksheet)
    end
  end
end