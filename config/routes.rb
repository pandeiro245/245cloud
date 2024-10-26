Rails.application.routes.draw do
  devise_for :users
  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}

  get '/auth/:provider/callback', to: 'users#login'

  get '/login', to: 'users#login_with_token'
  get '/sign_out', to: 'welcome#sign_out'

  get '/users', to: 'users#index'
  get '/redirect', to: 'welcome#redirect'

  get '/:id', to: 'users#show'
  get '/musics/:provider/:key', to: 'musics#index'
  get '/musics/:provider/:key/:key2', to: 'musics#index'


  namespace :api do
    get '/complete', to: 'workloads#complete'
    get '/users/:user_id/workloads', to: 'workloads#index'
    resources :workloads, only: [:index, :create]
    resources :comments, only: [:index, :create]
    resources :access_logs, only: [:create]
    get '/gyazo/proxy', to: 'gyazo#proxy'
  end
end
