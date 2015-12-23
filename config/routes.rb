Rails.application.routes.draw do
  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}
  get '/pitch' => 'welcome#pitch'
  get '/auth/timecrowd/callback', to: 'timecrowd#login'
  get '/timecrowd/recents' => 'timecrowd#recents'
  get '/timecrowd/start' => 'timecrowd#start'
  get '/timecrowd/stop' => 'timecrowd#stop'
end
