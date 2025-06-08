Rails.application.routes.draw do
  # レストラン検索のルート
  resources :restaurants, only: [:index]
  
  # ルートページをレストラン検索に設定
  root 'restaurants#index'
  
  # その他のルート...
end