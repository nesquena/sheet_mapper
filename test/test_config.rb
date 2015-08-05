require 'minitest/autorun'
require 'mocha/mini_test'
require 'fakeweb'
require 'ap'
require File.expand_path('../../lib/sheet_mapper', __FILE__)

Dir[File.expand_path("../test_helpers/*.rb", __FILE__)].each { |f| require f }
FakeWeb.allow_net_connect = false
Mocha::Configuration.prevent(:stubbing_non_existent_method)