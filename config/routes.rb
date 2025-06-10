Rails.application.routes.draw do
  # レストラン検索のルート
  resources :restaurants, only: [:index, :show]
  
  # ルートページをレストラン検索に設定
  root 'restaurants#index'

end