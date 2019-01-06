require 'bundler/setup'
require 'json'
require 'open-uri'
require 'yaml'

class WeatherInfo
  attr_reader :city_name, :datetimes

  @@base_url = YAML.load_file('./conf/config.yml')['BASE_URL']
  @@api_key = YAML.load_file('./conf/key.yml')['API_KEY']
  @@messages = File.open('./json/message.json') { |j| hash = JSON.load(j) }

  # コンストラクタ
  def initialize(area_name)
    if area_name
      @area_name = area_name
    elsif
      @area_name = YAML.load_file('./conf/config.yml')['DEFAULT_AREA']
    end
    fetch_area_id
    fetch_weather
  end

  # ベストな服装配列を返却
  def answer_clothes
    calculate_DI.map do |di|
      clothes_level = di.floor(-1)
      @@messages.fetch(clothes_level.to_s)
    end
  end

  # 服装と時刻情報を返却
  def answer_clothes_with_datetime
    @datetimes.zip(answer_clothes)
  end

  private #-----------------------private method-----------------------

  # 天気情報取得用地域ID取得
  def fetch_area_id
    area_list = File.open('./json/city.list.json') { |j| hash = JSON.load(j) }
    hash = area_list.map do |area|
      area if area.find { |_k, v| v == @area_name }
    end.compact
    if hash[0]
      @area_id = hash[0]['id']
    else raise '対応していないエリア名の可能性があります。エリア名の頭文字は大文字です。'
    end
  end

  # 天気情報取得 return json
  def fetch_weather
    @response = JSON.parse(open(@@base_url + "?id=#{@area_id}&APPID=#{@@api_key}").read)
    @city_name = @response['city']['name']
    @datetimes = @response['list'].map { |list| list['dt_txt'] }
  end

  # DI（不快指数）計算
  # DI = 0.81T + 0.01H * (0.99T - 14.3) + 46.3
  def calculate_DI
    di = @response['list'].map do |list|
      t = list['main']['temp'] - 273.15
      h = list['main']['humidity']
      0.81 * t + 0.01 * h * (0.99 * t - 14.3) + 46.3
    end
  end
end
