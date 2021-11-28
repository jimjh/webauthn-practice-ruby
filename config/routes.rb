Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users
  get '/hash_user_id', to: 'users#hash_user_id'
  get '/sign_in', to: 'users#sign_in'
  get '/credentials', to: 'users#credentials'
  post '/authenticate', to: 'users#authenticate'
end