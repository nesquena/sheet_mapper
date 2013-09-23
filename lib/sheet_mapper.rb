$:.unshift File.dirname(__FILE__)

require 'core_ext/hash_ext'   unless Hash.method_defined?(:symbolize_keys)
require 'core_ext/object_ext' unless Object.method_defined?(:present?)
require 'google_drive'
require 'sheet_mapper/version'
require 'sheet_mapper/collection'
require 'sheet_mapper/spreadsheet'
require 'sheet_mapper/base'

module SheetMapper

end
