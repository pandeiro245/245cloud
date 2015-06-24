Rails.application.routes.draw do
  resources :users, only: [:index]
  resources :workloads, only: [:index, :show, :new, :create, :update] do
    collection do
      get :cancel
      get :chatting
    end

    member do
      put :complete
    end
  end
  resources :musics, only: [:index]
  resources :you, only: [:index]
  resources :rooms, only: [:index, :show] do
    resources :comments, only: [:index, :create]
  end

  match '/auth/:provider/callback' => 'sessions#callback', via: [:get, :post]
  match '/auth/failure' => 'sessions#failure', via: [:get, :post]
  get '/logout' => 'welcome#logout' #TODO deleteメソッドでログアウトさせる
  get '/chatting' => 'welcome#chatting'

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
