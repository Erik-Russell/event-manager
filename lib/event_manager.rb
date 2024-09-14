# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = File.read('secret_file').strip

def clean_zipcode(zipcode)
  # handle nil value with #to_s
  # handle values < 5 with rjust
  # handle values > 5 with string#[0..4]
  zipcode.to_s.rjust(5, '0')[0..4]
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

    begin
      legislators = civic_info.representative_info_by_address(
        address: zipcode,
        levels: 'country',
        roles: %w[legislatorUpperBody legislatorLowerBody]
      )
      legislators = legislators.officials
    rescue StandardError
      'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end

    puts "#{name} #{zipcode} #{legislators}"
  end
rescue Errno::ENOENT
  puts 'ERROR => File does not exist.'
end
