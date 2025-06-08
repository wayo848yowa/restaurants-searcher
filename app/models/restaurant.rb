require 'net/http'
require 'json'
require 'uri'

class Restaurant
  # URLを作成,最後にuriクラスのインスタンスに変換
  def self.create_url(options = {})
    base_url = 'https://webservice.recruit.co.jp/hotpepper/gourmet/v1/'
    params = {
      key: '3b635989720cdb1a',
      format: 'json'
    }
    
    # オプションをマージ
    params.merge!(options)
    
    # URLエンコードしてクエリストリングを作成
    query_string = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
    url = "#{base_url}?#{query_string}"
    
    Rails.logger.info "API URL: #{url}" # デバッグ用
    url
  end

  # URL先にGETリクエストを送る,取得したJSON形式の文字列を返す
  def self.search(options = {})
    url = create_url(options)
    uri = URI.parse(url)
    
    begin
      response = Net::HTTP.get_response(uri)
      
      if response.code == '200'
        json_data = JSON.parse(response.body)
        Rails.logger.info "API Response: #{json_data.inspect}" # デバッグ用
        return json_data
      else
        Rails.logger.error "API Error: #{response.code} - #{response.message}"
        return nil
      end
    rescue => e
      Rails.logger.error "API Request Error: #{e.message}"
      return nil
    end
  end

  # 検索結果から店舗情報を整形して返す
  def self.format_results(api_response)
    return [] unless api_response && api_response['results'] && api_response['results']['shop']
    
    shops = api_response['results']['shop']
    shops.map do |shop|
      {
        id: shop['id'],
        name: shop['name'],
        address: shop['address'],
        access: shop['access'],
        genre: shop['genre']['name'],
        budget: shop['budget']['name'],
        urls: shop['urls']['pc'],
        photo: shop['photo']['pc']['l']
      }
    end
  end
end