require 'active_support/all'

class HotpepperService
  include HTTParty
  base_uri 'https://webservice.recruit.co.jp/hotpepper/gourmet/v1/'

  def initialize
    @api_key = ENV['HOTPEPPER_API_KEY']
  end

  def search_restaurants(keyword: nil, lat: nil, lng: nil, range: 5)
    params = {
      key: @api_key,
      format: 'json',
      count: 20
    }

    # キーワード検索
    params[:keyword] = keyword if keyword.present?

    # 位置情報検索
    if lat.present? && lng.present?
      params[:lat] = lat
      params[:lng] = lng
      params[:range] = range # 検索範囲(1:300m,2:500m,3:1000m,4:2000m,5:3000m)
    end

    response = self.class.get('/', query: params)

    if response.success?
      parse_response(response)
    else
      { error: "API Error: #{response.code}", restaurants: [] }
    end
  rescue StandardError => e
    { error: "Connection Error: #{e.message}", restaurants: [] }
  end

  private

  def parse_response(response)
    data = response.parsed_response

    if data['results'] && data['results']['shop']
      restaurants = data['results']['shop'].map do |shop|
        {
          id: shop['id'],
          name: shop['name'],
          access: shop['access'],
          # photo: shop.dig('photo', 'pc', 'm') || shop.dig('photo', 'mobile', 'l'),
          lat: shop['lat'],
          lng: shop['lng'],
          url: shop.dig('urls', 'pc')
        }
      end
      {
        total_count: data['results']['results_available'],
        restaurants: restaurants
      }
    else
      { error: 'No results found', restaurants: [] }
    end
  end
end
