require File.expand_path('../test_config.rb', __FILE__)

describe "Spreadsheet" do
  setup do
    @sheet_stub = stub(:sheet)
    @session_stub = stub(:session)
    ::GoogleDrive.expects(:login).with('login', 'pass').returns(@session_stub)
  end

  [:key, :url, :title].each do |identifier|
    context "for initialize by #{identifier}" do
      setup do
        @session_stub.expects(:"spreadsheet_by_#{identifier}").with('foo').returns(@sheet_stub)
        @sheet = SheetMapper::Spreadsheet.new(:mapper => Object, identifier => 'foo', :login => 'login', :password => 'pass')
      end

      should "not return spreadsheet class" do
        assert_kind_of SheetMapper::Spreadsheet, @sheet
      end

    end # initialize
  end

  context "for find_collection_by_title method" do
    setup do
      @session_stub.expects(:spreadsheet_by_key).with('foo').returns(@sheet_stub)
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
