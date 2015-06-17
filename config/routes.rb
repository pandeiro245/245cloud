Rails.application.routes.draw do
  resources :users, only: [:index]
  resources :workloads, only: [:show, :index, :create, :update] do
    collection do
      get :doings
      get :chattings
      get :dones
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

  get '/:id' => 'users#show'
  get '/musics/:id' => 'musics#show'
  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}
  resources :users, :workloads, :musics
end
