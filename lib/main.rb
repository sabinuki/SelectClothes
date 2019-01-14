require_relative 'weather_info'

area_name = ARGV

weather_info = WeatherInfo.new(area_name)

puts weather_info.answer_clothes
