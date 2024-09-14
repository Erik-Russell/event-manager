# frozen_string_literal: true

require 'csv'

puts ' **EventManager Initialized!**'

file_path = 'event_attendees.csv'

begin
  contents = CSV.open(
    file_path,
    headers: true,
    header_converters: :symbol
  )
  contents.each do |row|
    name = row[:first_name]
    zipcode = row[:zipcode]
    puts "#{name} #{zipcode}"
  end
rescue Errno::ENOENT
  puts 'ERROR => File does not exist.'
end
