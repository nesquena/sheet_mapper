require 'minitest/autorun'
require 'mocha'
require 'fakeweb'
require 'ap'
require File.expand_path('../../lib/sheet_mapper', __FILE__)

Dir[File.expand_path("../test_helpers/*.rb", __FILE__)].each { |f| require f }
FakeWeb.allow_net_connect = false

class MiniTest::Unit::TestCase
  include Mocha::API
end