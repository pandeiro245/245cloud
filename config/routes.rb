Rails.application.routes.draw do
  resources :users, only: [:index]
  resources :workloads, only: [:index, :create, :update] do
    collection do
      get :doings
      get :chattings
      get :dones
    end
  end
  resources :musics, only: [:index]
  resources :you, only: [:index]

  match '/auth/:provider/callback' => 'sessions#callback', via: [:get, :post]
  match '/auth/failure' => 'sessions#failure', via: [:get, :post]

  #devise_for :users, controllers: {
  #  omniauth_callbacks: "users/omniauth_callbacks"
  #}

  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}
  get '/pitch' => 'welcome#pitch'
  get '/auth/timecrowd/callback', to: 'timecrowd#login'
  get '/timecrowd/recents' => 'timecrowd#recents'
  post '/timecrowd/start' => 'timecrowd#start'
  get '/timecrowd/stop' => 'timecrowd#stop'
  resources :users, :workloads, :musics
end
