# frozen_string_literal: true

require 'csv'

puts ' **EventManager Initialized!**'

file_path = 'event_attendees.csv'

begin
  contents = CSV.open(file_path, headers: true)
  contents.each do |row|
    name = row[2]
    puts name
  end
rescue Errno::ENOENT
  puts 'ERROR => File does not exist.'
end
