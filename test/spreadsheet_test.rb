require File.expand_path('../test_config.rb', __FILE__)

describe "Spreadsheet" do
  setup do
    @sheet_stub = stub(:sheet)
    @session_stub = stub(:session)
    @session_stub.expects(:spreadsheet_by_key).with('foo').returns(@sheet_stub)
    ::GoogleSpreadsheet.expects(:login).with('login', 'pass').returns(@session_stub)
  end

  context "for initialize" do
    setup do
      @sheet = SheetMapper::Spreadsheet.new(:mapper => Object, :key => 'foo', :login => 'login', :password => 'pass')
    end

    should "return spreadsheet class" do
      assert_kind_of SheetMapper::Spreadsheet, @sheet
    end

    should "have access to readers" do
      assert_equal Object, @sheet.mapper
      assert_equal @session_stub, @sheet.session
      assert_equal @sheet_stub, @sheet.spreadsheet
    end
  end # initialize

  context "for find_collection_by_title method" do
    setup do
      @sheet = SheetMapper::Spreadsheet.new(:mapper => Object, :key => 'foo', :login => 'login', :password => 'pass')
      @work_stub = stub(:worksheet)
      @work_stub.expects(:title).returns("FOO")
      @sheet_stub.expects(:worksheets).returns([@work_stub])
      @collection = @sheet.find_collection_by_title("foo")
    end

    should "return the expected collection" do
      assert_kind_of SheetMapper::Collection, @collection
      assert_equal @work_stub, @collection.worksheet
    end
  end # find_collection_by_title
end # Spreadsheet
