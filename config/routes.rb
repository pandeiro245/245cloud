Rails.application.routes.draw do
  devise_for :users
  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}
  resources :ruffnotes, only: [:index]

  get '/auth/timecrowd/callback', to: 'timecrowd#login'
  get '/timecrowd/recents' => 'timecrowd#recents'
  post '/timecrowd/start' => 'timecrowd#start'
  post '/timecrowd/stop' => 'timecrowd#stop'

  post '/toggl/start' => 'toggl#start'
  post '/toggl/stop'  => 'toggl#stop'

  get '/auth/facebook/callback', to: 'facebook#login'

  get '/:id', to: 'users#show'
  get '/musics/:provider/:key', to: 'musics#index'
  get '/musics/:provider/:key/:key2', to: 'musics#index'

  namespace :api do
    get '/complete', to: 'workloads#complete'
    get '/users/:facebook_id/workloads', to: 'workloads#index'
    resources :workloads, only: [:index, :create]
    resources :comments, only: [:index, :create]
    resources :access_logs, only: [:create]
  end
end
