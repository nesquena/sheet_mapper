gem 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'mocha' # Load mocha after minitest

begin
  require 'ruby-debug'
rescue LoadError; end

class MiniTest::Spec
  class << self
    alias :setup :before unless defined?(Rails)
    alias :teardown :after unless defined?(Rails)
    alias :should :it
    alias :context :describe
    def should_eventually(desc)
      it("should eventually #{desc}") { skip("Should eventually #{desc}") }
    end
  end
  alias :assert_no_match  :refute_match
  alias :assert_not_nil   :refute_nil
  alias :assert_not_equal :refute_equal

  # assert_same_elements([:a, :b, :c], [:c, :a, :b]) => passes
  def assert_same_elements(a1, a2, msg = nil)
    [:select, :inject, :size].each do |m|
      [a1, a2].each {|a| assert_respond_to(a, m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}.") }
    end

    assert a1h = a1.inject({}) { |h,e| h[e] ||= a1.select { |i| i == e }.size; h }
    assert a2h = a2.inject({}) { |h,e| h[e] ||= a2.select { |i| i == e }.size; h }

    assert_equal(a1h, a2h, msg)
  end

  #   assert_contains(['a', '1'], /\d/) => passes
  #   assert_contains(['a', '1'], 'a') => passes
  #   assert_contains(['a', '1'], /not there/) => fails
  def assert_contains(collection, x, extra_msg = "")
    collection = [collection] unless collection.is_a?(Array)
    msg = "#{x.inspect} not found in #{collection.to_a.inspect} #{extra_msg}"
    case x
    when Regexp
      assert(collection.detect { |e| e =~ x }, msg)
    else
      assert(collection.include?(x), msg)
    end
  end

  # Asserts that the given collection does not contain item x.  If x is a regular expression, ensure that
  # none of the elements from the collection match x.
  def assert_does_not_contain(collection, x, extra_msg = "")
    collection = [collection] unless collection.is_a?(Array)
    msg = "#{x.inspect} found in #{collection.to_a.inspect} " + extra_msg
    case x
    when Regexp
      assert(!collection.detect { |e| e =~ x }, msg)
    else
      assert(!collection.include?(x), msg)
    end
  end
end # MiniTest::Spec

class ColoredIO
  def initialize(io)
    @io = io
  end

  def print(o)
    case o
    when "." then @io.send(:print, o.green)
    when "E" then @io.send(:print, o.yellow)
    when "F" then @io.send(:print, o.red)
    when "S" then @io.send(:print, o.magenta)
    else @io.send(:print, o)
    end
  end

  def puts(*o)
    super
  end
end

MiniTest::Unit.output = ColoredIO.new(MiniTest::Unit.output)