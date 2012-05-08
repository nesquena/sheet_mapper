module SheetMapper
  class Collection
    attr_reader :records

    def initialize(spreadsheet, worksheet)
      @spreadsheet = spreadsheet
      @worksheet   = worksheet
      @mapper      = @spreadsheet.mapper
      @records     = process_records!
    end

    # @collection.each { |m| ...mapped obj... }
    def each(&block)
      records.each(&block)
    end

    def rows
      @worksheet.rows
    end

    def cell(row, col)
      @worksheet[row, col]
    end

    protected

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