Rails.application.routes.draw do
  resources :users, :workloads, :musics
  root 'welcome#index'

  match '/auth/:provider/callback' => 'sessions#callback', via: [:get, :post]
  match '/auth/failure' => 'sessions#failure', via: [:get, :post]
end
