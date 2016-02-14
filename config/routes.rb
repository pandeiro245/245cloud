Rails.application.routes.draw do
  devise_for :users
  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}
  get '/pitch' => 'welcome#pitch'

  get '/auth/timecrowd/callback', to: 'timecrowd#login'
  get '/timecrowd/recents' => 'timecrowd#recents'
  post '/timecrowd/start' => 'timecrowd#start'
  post '/timecrowd/stop' => 'timecrowd#stop'

  post '/toggl/start' => 'toggl#start'
  post '/toggl/stop'  => 'toggl#stop'

  get '/auth/facebook/callback', to: 'facebook#login'
  get '/parse_login', to: 'facebook#parse_login'

  namespace :api do
    get '/complete', to: 'workloads#complete'
    get '/dones', to: 'workloads#dones'
    get '/yours', to: 'workloads#yours'
    get '/chattings', to: 'workloads#chattings'
    get '/playings', to: 'workloads#playings'
    resources :workloads, only: [:create]
    resources :comments, only: [:index, :create]
  end
end
