require 'rubygems'
require 'active_support/all'
require 'google_spreadsheet'
require File.expand_path('lib/sheet_mapper')

class GradeMapper < SheetMapper::Base
  columns :topic, :grade, :score

  def valid_row?
    self[:topic].present? && @pos > 4
  end

  # Convert is_notable to boolean
  def score
    self[:score].to_i
  end
end

sheet = SheetMapper::Spreadsheet.new(:mapper => GradeMapper, :key => ENV['SHEET_KEY'], :login => ENV['SHEET_LOGIN'], :password => ENV['SHEET_PASS'])
collection = sheet.find_collection_by_title('data')

name        = collection.cell(1, 2)
age         = collection.cell(2, 2)

puts "Name: #{name}, Age: #{age}"

bubbles = collection.each do |bubble|
  p bubble.attributes # => { :topic => "...", :grade => "...", :score => "..." }
end

b = collection.records[1]
b[:grade] = "B"
b[:score] = 86

collection.save

