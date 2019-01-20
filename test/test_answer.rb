require 'minitest/autorun'
require './lib/answer'
require 'open-uri'
require 'yaml'

class TestAnswer < Minitest::Test
  def setup
    # id:1850147 = Tokyo
    area_id = 1_850_147
    base_url = YAML.load_file('./conf/config.yml')['BASE_URL']
    api_key = YAML.load_file('./conf/key.yml')['API_KEY']
    response = JSON.parse(open(base_url + "?id=#{area_id}&APPID=#{api_key}").read)
    @answer = Answer.new(response)
  end

  # 対象外時間帯の情報が削除されているかテスト
  def test_reject_timezone
    exclude_time = ['03:00:00', '09:00:00', '15:00:00', '21:00:00']
    response = @answer.reject_timezone
    assert_equal(false, response.all? do |res|
     res.has_value?(exclude_time[0]) || res.has_value?(exclude_time[1]) || res.has_value?(exclude_time[2]) || res.has_value?(exclude_time[3])
    end)
  end
end
