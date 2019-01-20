require 'bundler/setup'
require 'json'
require 'open-uri'
require 'yaml'
require_relative './Answer'

class WeatherInfo
  @@base_url = YAML.load_file('./conf/config.yml')['BASE_URL']
  @@api_key = YAML.load_file('./conf/key.yml')['API_KEY']
  @@messages = File.open('./json/message.json') { |j| hash = JSON.load(j) }
  @@area_list = File.open('./json/city.list.json') { |j| hash = JSON.load(j) }

  # 除外時刻
  @@exclude_time = ['00:00:00', '03:00:00']

  # コンストラクタ
  def initialize(area_name)
    if area_name
      @area_name = area_name.collect(&:capitalize).join(' ')
    elsif
      @area_name = YAML.load_file('./conf/config.yml')['DEFAULT_AREA']
    end
  end

  # ベストな服装配列を返却
  def answer_clothes
    match_area = @@area_list.map do |area|
      area if area.find { |_k, v| v == @area_name }
    end.compact

    if match_area[0]
      area_id = match_area[0]['id']
      response = JSON.parse(open(@@base_url + "?id=#{area_id}&APPID=#{@@api_key}").read)
      answer = Answer.new(response)
      answer.return_answer
    else
      guess_area
    end
  end

  # 入力された地域名から前方3文字で該当地域検索
  def guess_area
    search_str = @area_name.slice(0..3)
    area_candidate = @@area_list.map do |area|
      area if area.find { |_k, v| v =~ /#{search_str}/ }
    end.compact
    area_candidate.map do |candidate|
      candidate['name']
    end.unshift('該当する地域名がありません。') << '--------------------'
  end
end
