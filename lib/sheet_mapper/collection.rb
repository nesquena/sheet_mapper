require 'delegate'

module SheetMapper
  class CollectionNotFound < StandardError; end

  class Collection < SimpleDelegator
    attr_reader :records, :worksheet

    # spreadsheet is a SheetMapper::Spreadsheet
    # SheetMapper::Collection.new(@sheet, @work)
    def initialize(spreadsheet, worksheet)
      @spreadsheet = spreadsheet
      @worksheet   = worksheet
      @mapper      = @spreadsheet.mapper
      @records     = process_records!
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
    # @collection.save(@record)
    def save(records=@records)
      Array(records).each { |r| @worksheet.update_cells(r.pos, 1, [r.attribute_values]) if r.changed? }
      @worksheet.save
    end

    # Reload worksheet discarding changes not saved
    def reload
      @worksheet.reload
      @records = process_records!
    end

    def __getobj__
      @records
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