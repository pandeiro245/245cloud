Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}
  resources :users, :workloads, :musics
end
