class RestaurantsController < ApplicationController
  def index
    @restaurants = []
    @error_message = nil
    @search_params = {
      range: params[:range],
      lat: params[:lat],
      lng: params[:lng]
    }

    return unless params[:lat].present? && params[:lng].present?

    search_restaurants

    if @restaurants.present? || (@search_params[:lat].present? && @search_params[:lng].present?)
      render :result
    else
      render :index
    end
  end

  def show
    restaurant_id = params[:id]

    # セッションから検索結果を取得
    if session[:restaurants_data]
      @restaurant = session[:restaurants_data].find { |r| r[:id] == restaurant_id }.page(params[:page])
    end

    # セッションにデータがない場合は、APIから再検索
    if @restaurant.nil?
      search_options = {
        id: restaurant_id
      }

      api_response = Restaurant.search(search_options)

      if api_response && api_response['results'] && api_response['results']['shop']
        shops = Restaurant.format_results(api_response)
        @restaurant = shops.first
      end
    end

    if @restaurant.nil?
      redirect_to restaurants_path, alert: 'レストランが見つかりませんでした。'
    else
      render :detail
    end
  end

  private

  def search_restaurants
    # 検索オプションを作成
    search_options = make_search_options

    # APIを呼び出し
    api_response = Restaurant.search(search_options)

    if api_response
      @restaurants = Restaurant.format_results(api_response)
      @total_count = api_response.dig('results', 'results_returned') || 0

      
      
      # kaminariを使ってページング実装
      @restaurants = Kaminari.paginate_array(@restaurants).page(params[:page]).per(2)

      # 検索結果をセッションに保存（詳細ページで使用するため）
      session[:restaurants_data] = all_restaurants

    else
      @error_message = '検索中にエラーが発生しました。'
    end
  rescue StandardError => e
    Rails.logger.error "Search Error: #{e.message}"
    @error_message = "検索中にエラーが発生しました: #{e.message}"
  end

  def make_search_options
    options = {}

    # 位置情報（必須）
    options[:lat] = params[:lat] if params[:lat].present?
    options[:lng] = params[:lng] if params[:lng].present?

    # 検索範囲
    range = params[:range].to_i
    options[:range] = if range.between?(1, 5)
                        range
                      else
                        3 # デフォルト値
                      end

    # その他のオプション
    options[:count] = 50 # 取得件数
    options[:order] = 4  # 距離順

    options
  end
end
