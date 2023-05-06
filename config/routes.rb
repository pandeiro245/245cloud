Rails.application.routes.draw do
  devise_for :users
  root 'home#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}

  get '/auth/:provider/callback', to: 'users#login'

  get '/login', to: 'users#login_with_token'

  get '/users', to: 'users#index'

  get '/:id', to: 'users#show'

  namespace :api do
    get '/complete', to: 'workloads#complete'
    get '/users/:user_id/workloads', to: 'workloads#index'
    resources :workloads, only: [:index, :create]
    resources :comments, only: [:index, :create]
    resources :access_logs, only: [:create]
    get '/gyazo/proxy', to: 'gyazo#proxy'
  end
end
