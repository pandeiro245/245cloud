Rails.application.routes.draw do
  resources :users, only: [:index]
  resources :workloads, only: [:index]
  resources :musics, only: [:index]
  resources :you, only: [:index]

  # omniauth
  match '/auth/:provider/callback' => 'sessions#callback', via: [:get, :post]
  match '/auth/failure' => 'sessions#failure', via: [:get, :post]
  root 'welcome#index'
end
