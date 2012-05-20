module SheetMapper
  class CollectionNotFound < StandardError; end

  class Collection
    attr_reader :records, :worksheet

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

    # Saves the records that have changed back to spreadsheet
    # @collection.save
    def save
      return unless @records.present?
      @worksheet.update_cells(@records.first.pos, 1, @records.map(&:attribute_values))
      @worksheet.save
    end

    # Reload worksheet discarding changes not saved
    def reload
      @worksheet.reload
      @records = process_records!
    end

    protected

    # Converts all valid raw data hashes into mapped records
    # process_records! => [<SheetMapper::Base>, ...]
    def process_records!
      records = []
      @worksheet.rows.each_with_index do |record, index|
        record = @mapper.new(index + 1, record)
        records << record if record.valid_row?
      end
      records
    end
  end
end