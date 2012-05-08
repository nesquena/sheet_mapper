=begin

 class BubbleMapper < SheetMapper::Base
   attributes :offset_seconds, :body, :link_url, :category
 end

 sheet = SheetMapper::Worksheet.new(:mapper => BubbleMapper, :key => 'sheet_key', :login => 'user', :password => 'pass')
 collection = sheet.find_collection_by_title('title')
 bubbles = collection.each do |bubble|
   p bubble.to_hash
 end

=end

require 'rubygems'
require 'active_support/all'
require 'google_spreadsheet'
require File.expand_path('lib/sheet_mapper')

class BubbleMapper < SheetMapper::Base
  columns :offset_seconds, :is_notable, :category, :body, :image_url, :link_text, :link_url

  def valid_row?
    self[:body].present? && @pos > 7
  end

  def offset_seconds
    return unless self[:offset_seconds].strip =~ /^[\d\:]+$/ # Only return offset if valid digits
    offset = self[:offset_seconds].strip.split(':')
    (offset[0].to_i * 60) + offset[1].to_i
  end

  # Convert is_notable to boolean
  def is_notable
    self[:is_notable].to_s.match(/true/i).present?
  end
end

sheet = SheetMapper::Spreadsheet.new(:mapper => BubbleMapper, :key => ENV['SHEET_KEY'], :login => ENV['SHEET_LOGIN'], :password => ENV['SHEET_PASS'])
collection = sheet.find_collection_by_title('s2e5')

media_id        = collection.cell(2, 2)
season_num      = collection.cell(3, 2)
episode_num     = collection.cell(4, 2)
user_id         = collection.cell(5, 2)
duration        = collection.cell(6, 2)

puts "Media: #{media_id}, User: #{user_id}"

bubbles = collection.each do |bubble|
  p bubble.attributes
end

