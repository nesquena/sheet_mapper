require File.expand_path('../test_config.rb', __FILE__)

class TestMapper
  attr_reader :index, :record

  def initialize(index, record)
    @index  = index
    @record = record
  end

  def tuple; [name, age]; end
  def name; record[:name]; end
  def age;  record[:age]; end
  def valid_row?; true; end
  def pos; 3; end
  def attribute_values; tuple; end
  def changed?; true; end
end # TestMapper

describe "Collection" do
  setup do
    @worksheet   = stub(:rows => [{ :name => "Bob", :age => 21 }, { :name => "Susan", :age => 34 }, { :name => "Joey", :age => 67 }])
    @spreadsheet = stub(:mapper => TestMapper)
  end

  context "for worksheet accessor" do
    setup do
      @collection = SheetMapper::Collection.new(@spreadsheet, @worksheet)
    end

    should "return worksheet from accessor" do
      assert_equal @worksheet, @collection.worksheet
    end
  end # worksheet

  context "Enumerability" do
    subject do
      @collection = SheetMapper::Collection.new(@spreadsheet, @worksheet)
    end

    should "behave like an Enumerable" do
      assert_equal subject.first, subject.records.first
      assert subject.respond_to?(:each)
      assert subject.respond_to?(:find)
      assert subject.respond_to?(:map)
    end
  end # enum

  context "for rows method" do
    setup do
      @collection = SheetMapper::Collection.new(@spreadsheet, @worksheet)
    end

    should "return raw data hashes" do
      rows = @collection.rows
      assert_equal ["Bob", 21], [rows[0][:name], rows[0][:age]]
      assert_equal ["Susan", 34], [rows[1][:name], rows[1][:age]]
      assert_equal ["Joey", 67], [rows[2][:name], rows[2][:age]]
    end
  end # rows

  context "for cell method" do
    setup do
      @worksheet.expects(:[]).with(4,5).returns("foo")
      @collection = SheetMapper::Collection.new(@spreadsheet, @worksheet)
    end

    should "return raw data in worksheet" do
      assert_equal "foo", @collection.cell(4,5)
    end
  end # cell

  context "for records method" do
    setup do
      @collection = SheetMapper::Collection.new(@spreadsheet, @worksheet)
    end

    should "support iterating each mapped row" do
      rows = @collection.records
      assert_equal 3, rows.size
      assert_equal ["Bob", 21], rows[0].tuple
      assert_equal ["Susan", 34], rows[1].tuple
      assert_equal ["Joey", 67], rows[2].tuple
    end
  end # records

  context "for save method" do
    setup do
      @collection = SheetMapper::Collection.new(@spreadsheet, @worksheet)
      @rows = @collection.records
    end

    should "persist back to worksheet all rows" do
      @rows.each { |r| @worksheet.expects(:update_cells).with(r.pos, 1, [r.attribute_values]) }
      @worksheet.expects(:save).once
      @collection.save
    end

    should "persist back to worksheet one row" do
      first_row = @collection.records.first
      @worksheet.expects(:update_cells).with(first_row.pos, 1, [first_row.attribute_values])
      @worksheet.expects(:save).once
      @collection.save(first_row)
    end
  end # save

  context "for reload method" do
    setup do
      @collection = SheetMapper::Collection.new(@spreadsheet, @worksheet)
    end

    should "persist back to worksheet" do
      @worksheet.expects(:reload).once
      @collection.reload
    end
  end # reload
end