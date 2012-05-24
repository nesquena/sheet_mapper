require File.expand_path('../test_config.rb', __FILE__)

class TestBase < SheetMapper::Base
  columns :name, :age
  columns :color

  def age
    self[:age] * 2
  end

  def age=(val)
    self[:age] = val / 2
  end

  def name
    self[:name].upcase
  end
end

class TestBaseExt < TestBase; end

describe "Base" do
  setup do
    @data = ["Bob", 21, "Red"]
  end

  should "support columns class accessor" do
    assert_equal [:name, :age, :color], TestBase.columns
  end # columns

  should "support pos instances accessor" do
    @test = TestBase.new(1, @data)
    assert_equal 1, @test.pos
  end # pos

  context "for attribute methods" do
    setup do
      @test = TestBase.new(1, @data)
    end

    should "return attribute hash" do
      assert_equal "BOB", @test.name
      assert_equal 42, @test.age
      assert_equal "Red", @test.color
    end
  end # attribute methods

  context "for assignment of attributes" do
    setup do
      @test = TestBase.new(1, @data)
    end

    should "allow assignments" do
      @test.age   = 46
      @test.color = "Black"
      assert_equal 23, @test[:age]
      assert_equal "Black", @test[:color]
    end
  end # assignment of attributes

  context "for attributes method" do
    setup do
      @test = TestBase.new(1, @data)
    end

    should "return attributes hash" do
      hash = @test.attributes
      assert_equal "BOB", hash[:name]
      assert_equal 42, hash[:age]
      assert_equal "Red", hash[:color]
    end
  end # attributes method

  context "for accessing attribute" do
    setup do
      @test = TestBase.new(1, @data)
    end

    should "return value of attribute" do
      assert_equal "Bob", @test[:name]
    end
  end # access []

  context "for assigning attributes" do
    setup do
      @test = TestBase.new(1, @data)
      @test[:age] = 45
    end

    should "have new value assigned" do
      assert_equal 45, @test[:age]
    end
  end # assign []=

  context "for color attribute accessor" do
    setup do
      @test = TestBase.new(1, @data)
      @test_ext = TestBaseExt.new(1, @data)
    end

    should "support color auto accessor" do
      assert_equal "Red", @test.color
      assert_equal "Red", @test_ext.color
    end

    should "support color auto assigner" do
      @test.color = "Blue"
      assert_equal "Blue", @test.color
    end

    should "respond to color auto accessor" do
      assert_respond_to @test, :color
      assert_respond_to @test_ext, :color
    end
  end

  context "for attribute_values method" do
    setup do
      @test = TestBase.new(1, @data)
      @test[:age] = 45
    end

    should "return attribute values in proper order as list" do
      assert_equal ["Bob", 45, "Red"], @test.attribute_values
    end
  end # attribute_values

  context "for changed? method" do
    setup do
      @test = TestBase.new(1, @data)
    end

    should "return false if not changed" do
      @test[:age] = 21
      assert_equal false, @test.changed?
    end

    should "return true if changed" do
      @test[:age] = 45
      assert_equal true, @test.changed?
    end
  end # attribute_values
end # Base