# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

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
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts ' **EventManager Initialized!**'

attendee_list_file = 'event_attendees.csv'
template_letter_file = 'form_letter.erb'

begin
  contents = CSV.open(
    attendee_list_file,
    headers: true,
    header_converters: :symbol
  )

  template_letter = File.read(template_letter_file)
  erb_template = ERB.new template_letter

  contents.each do |row|
    id = row[0].to_s.rjust(2, '0')
    name = row[:first_name]

    zipcode = clean_zipcode(row[:zipcode])

    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id, form_letter)

    puts "file #{id} complete"
  end
rescue Errno::ENOENT
  puts 'ERROR => File does not exist.'
end
