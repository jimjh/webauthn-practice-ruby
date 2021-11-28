Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users
  get '/register_options', to: 'users#register_options'
  get '/sign_in', to: 'users#sign_in'
  get '/authenticate_options', to: 'users#authenticate_options'
  post '/authenticate', to: 'users#authenticate'
end