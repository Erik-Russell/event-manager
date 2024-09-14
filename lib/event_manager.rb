# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'

def clean_zipcode(zipcode)
  # handle nil value with #to_s
  # handle values < 5 with rjust
  # handle values > 5 with string#[0..4]
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read('secret_file').strip

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    )
    legislators = legislators.officials
    legislators_names = legislators.map(&:name)
    legislators_names.join(', ')
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

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

    zipcode = clean_zipcode(row[:zipcode])

    legislators = legislators_by_zipcode(zipcode)

    puts "#{name} #{zipcode} #{legislators}"
  end
rescue Errno::ENOENT
  puts 'ERROR => File does not exist.'
end
