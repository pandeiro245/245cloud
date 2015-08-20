Rails.application.routes.draw do
  resources :users, only: [:index]
  resources :rooms, only: [:show]
  resources :musics, only: [:index]
  resources :places
  resources :workloads, only: [:index, :show, :new, :create, :update]
  resources :comments, only: [:create]

  match '/auth/:provider/callback' => 'sessions#callback', via: [:get, :post]
  match '/auth/failure' => 'sessions#failure', via: [:get, :post]
  get '/logout' => 'welcome#logout' #TODO deleteメソッドでログアウトさせる

  get '/recent' => 'welcome#recent'
  get '/:id' => 'users#show'
  get '/musics/random' => 'musics#random'
  get '/musics/:id' => 'musics#show'
  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}
  get '/pitch' => 'welcome#pitch'
  get '/auth/timecrowd/callback', to: 'timecrowd#login'
  get '/timecrowd/recents' => 'timecrowd#recents'
  post '/timecrowd/start' => 'timecrowd#start'
  get '/timecrowd/stop' => 'timecrowd#stop'
  resources :users, :workloads, :musics
end
