Rails.application.routes.draw do
  mount KintoneSync::Engine, at: '/kintone_sync', as: :kintone_sync if defined? KintoneSync::Engine

  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}
  get '/pitch' => 'welcome#pitch'
  get '/auth/timecrowd/callback', to: 'timecrowd#login'
  get '/timecrowd/recents' => 'timecrowd#recents'
  post '/timecrowd/start' => 'timecrowd#start'
  get '/timecrowd/stop' => 'timecrowd#stop'
end
