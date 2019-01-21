require 'bundler/setup'
require 'json'
require 'open-uri'

class Answer
  # 回答対象外時刻
  @@exclude_time = ['03:00:00', '09:00:00', '15:00:00', '21:00:00']
  # 回答メッセージリスト
  @@messages = File.open('./json/message.json') { |j| hash = JSON.load(j) }

  # コンストラクタ
  def initialize(response)
    @response = response.dup
    reject_timezone
  end

  # 不要な時間帯の情報を削除
  def reject_timezone
    @response['list'].delete_if do |list|
      list['dt_txt'].include?(@@exclude_time[0]) || list['dt_txt'].include?(@@exclude_time[1]) || list['dt_txt'].include?(@@exclude_time[2]) || list['dt_txt'].include?(@@exclude_time[3])
    end
  end

  # 回答を返却
  def return_answer
    answer = @response['list'].map do |res|
      datetime = res['dt_txt']
      weather = res['weather'][0]['description']
      temp = res['main']['temp'] - 273.15
      humidity = res['main']['humidity']
      di = calculate_DI(res)
      message = @@messages.fetch(di.floor(-1).to_s)
      { datetime: datetime, weather: weather, temp: temp, humidity: humidity, message: message, di: di }
    end
  end

  # DI（不快指数）計算
  # DI = 0.81T + 0.01H * (0.99T - 14.3) + 46.3
  def calculate_DI(response)
    t = response['main']['temp'] - 273.15
    h = response['main']['humidity']
    di = 0.81 * t + 0.01 * h * (0.99 * t - 14.3) + 46.3
    return di if di >= 0
    return 0 if di < 0
  end
end
