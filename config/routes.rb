Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  devise_for :users
  root 'home#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}
  get '/prompts', to: 'prompts#index'
  get '/prompts/rspec', to: 'prompts#rspec'
  get '/prompts/rubocop', to: 'prompts#rubocop'

  get '/auth/:provider/callback', to: 'users#login'

  get '/login', to: 'users#login_with_token'

  get '/users', to: 'users#index'
  get '/redirect', to: 'home#redirect'
  get '/playing', to: 'home#playing'
  get '/chatting', to: 'home#chatting'
  get '/error', to: 'home#error'

  get '/:id', to: 'users#show'
  get '/musics/:provider/:key', to: 'musics#index'
  get '/musics/:provider/:key/:key2', to: 'musics#index'

  namespace :api do
    get '/workloads/download', to: 'workloads#download'
    get '/comments/download', to: 'comments#download'

    get '/complete', to: 'workloads#complete'
    get '/users/:user_id/workloads', to: 'workloads#index'
    resources :workloads, only: [:index, :create]
    resources :comments, only: [:index, :create]
    resources :access_logs, only: [:create]
    get '/gyazo/proxy', to: 'gyazo#proxy'
  end
end
