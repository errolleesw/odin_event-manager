require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'



def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)

  Dir.mkdir('output') unless Dir.exist?('output') # create output directory unless one already exists

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file| # if the file doesn't exist, file will be created. If exists, then it will be destroyed.
    file.puts form_letter
  end
end

def clean_phone_number(phone_number)
  phone_number = phone_number.gsub(/[^0-9]/, '')
  if phone_number.length == 11 && phone_number[0] == 1
    phone_number = phone_number[1..10]
  elsif phone_number.length == 11 || phone_number.length < 10
    phone_number = '0000000000'
  else
    phone_number = phone_number
  end
end

def format_phone_number(phone_number)
  phone_number = phone_number.gsub(/[^0-9]/, '')
  return '000-000-0000' unless phone_number.length == 10
  "#{phone_number[0..2]}-#{phone_number[3..5]}-#{phone_number[6..9]}"
end

def find_most_common(array)
  array.max_by { |element| array.count(element) }
end

def parse_time(regdate)
  DateTime.strptime(regdate, '%m/%d/%y %H:%M').hour
end

def parse_day(regdate)
  DateTime.strptime(regdate, '%m/%d/%y %H:%M').strftime('%A')
end


puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

phone_numbers = []
registration_hours = []
registration_days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  phone_number = format_phone_number(phone_number)
  phone_numbers << phone_number
  registration_hours << parse_time(row[:regdate])
  registration_days << parse_day(row[:regdate])
  # reg_date = Time.strptime(row[:regdate], '%m/%d/%y %H:%M')
  # hour = reg_date.hour
  # hours[hour] += 1
  # phone_number = row[:homephone]
  # legislators = legislators_by_zipcode(zipcode)

  # puts "#{name} #{phone_number}"
  # form_letter = erb_template.result(binding)
  # save_thank_you_letter(id,form_letter)

end

most_common_hour = find_most_common(registration_hours)
most_common_day = find_most_common(registration_days)

puts "Most common registration hour: #{most_common_hour}"
puts "Most common registration day: #{most_common_day}"

# most_popular_hour = hours.max_by{|hour, count| count}[0]
# p hours
# puts "Most popular hour: #{most_popular_hour}"