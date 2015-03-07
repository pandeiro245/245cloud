Rails.application.routes.draw do
  resources :users, only: [:index]
  resources :workloads, only: [:index]
  resources :musics, only: [:index]
  resources :you, only: [:index]

  match '/auth/:provider/callback' => 'sessions#callback', via: [:get, :post]
  match '/auth/failure' => 'sessions#failure', via: [:get, :post]

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  root 'welcome#index'
end

