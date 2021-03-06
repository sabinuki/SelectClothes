require_relative 'weather_info'

area_name = ARGV
weather_info = WeatherInfo.new(area_name)
answer = weather_info.answer_clothes

if answer
  answer.each do |ans|
    puts "日付：#{ans[:datetime]} 天気：#{ans[:weather]} 気温：#{ans[:temp].floor(2)}度 湿度：#{ans[:humidity]}％ 服装：#{ans[:message]} 不快指数：#{ans[:di].floor(2)}"
  end
else
  puts weather_info.guess_area
end
