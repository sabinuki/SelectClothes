require_relative 'weather_info'

ARGV.each do |arg|
  @area_name = arg
end

weather_info = WeatherInfo.new(@area_name)

puts 'Area Name: ' + weather_info.city_name
puts weather_info.answer_clothes_with_datetime
