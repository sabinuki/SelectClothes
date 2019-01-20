require 'minitest/autorun'
require './lib/weather_info'

class TestWeatherInfo < Minitest::Test
  def setup
    area_name = Array['tokyo']
    @weather_info = WeatherInfo.new(area_name)
  end

  def test_initialize_default_city
    area_name = Array['']
    weather_info = WeatherInfo.new(area_name)
    assert weather_info
  end

  def test_fetch_answer_clothes
    assert @weather_info.answer_clothes
  end

  def test_fetch_guess_arealist
    area_name = Array['testcity']
    weather_info = WeatherInfo.new(area_name)
    assert weather_info.answer_clothes
  end
end
