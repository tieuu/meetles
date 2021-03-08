Rails.application.routes.draw do
  resources :meetles, only: [ :create, :index, :show, :update ] do
    resources :result_stations, only: [ :update ]
  end
  root to: 'pages#home'
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
