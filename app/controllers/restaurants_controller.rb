class RestaurantsController < ApplicationController
  
  def index
    @restaurants = []
    @error_message = nil
    @search_params = {
      range: params[:range],
      lat: params[:lat],
      lng: params[:lng]
    }
    
    if params[:lat].present? && params[:lng].present?
      search_restaurants
    end
  end

  private

  def search_restaurants
    begin
      # 検索オプションを作成
      search_options = make_search_options
      
      # APIを呼び出し
      api_response = Restaurant.search(search_options)
      
      if api_response
        @restaurants = Restaurant.format_results(api_response)
        @total_count = api_response.dig('results', 'results_returned') || 0
      else
        @error_message = "検索中にエラーが発生しました。"
      end
      
    rescue => e
      Rails.logger.error "Search Error: #{e.message}"
      @error_message = "検索中にエラーが発生しました: #{e.message}"
    end
  end

  def make_search_options
    options = {}
    
    # 位置情報（必須）
    options[:lat] = params[:lat] if params[:lat].present?
    options[:lng] = params[:lng] if params[:lng].present?
    
    # 検索範囲
    range = params[:range].to_i
    if range.between?(1, 5)
      options[:range] = range
    else
      options[:range] = 3 # デフォルト値
    end
    
    # その他のオプション
    options[:count] = 20 # 取得件数
    options[:order] = 4  # 距離順
    
    options
  end
end