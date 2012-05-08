module SheetMapper
  class CollectionNotFound < StandardError; end

  class Collection
    attr_reader :records

    # spreadsheet is a SheetMapper::Spreadsheet
    # SheetMapper::Collection.new(@sheet, @work)
    def initialize(spreadsheet, worksheet)
      @spreadsheet = spreadsheet
      @worksheet   = worksheet
      @mapper      = @spreadsheet.mapper
      @records     = process_records!
    end

    # Each block for every mapped record
    # @collection.each { |m| ...mapped obj... }
    def each(&block)
      records.each(&block)
    end

    # Returns an array of mapped records
    # @collection.rows => [<SheetMapper::Base>, ...]
    def rows
      @worksheet.rows
    end

    # Returns raw value from worksheet cell
    # @collection.cell(4, 5) => "Bob"
    def cell(row, col)
      @worksheet[row, col]
    end

    protected

    # Converts all valid raw data hashes into mapped records
    # process_records! => [<SheetMapper::Base>, ...]
    def process_records!
      records = []
      @worksheet.rows.each_with_index do |record, index|
        record = @mapper.new(index, record)
        records << record if record.valid_row?
      end
      records
    end
  end
end