Rails.application.routes.draw do
  match '/auth/:provider/callback' => 'sessions#callback', via: [:get, :post]
  match '/auth/failure' => 'sessions#failure', via: [:get, :post]
  get '/logout' => 'welcome#logout' #TODO deleteメソッドでログアウトさせる

  get '/dones' => 'workloads#dones'
  get '/doings' => 'workloads#doings'
  get '/chattings' => 'workloads#chattings'

  get '/musics/random' => 'musics#random'
  get '/musics/:id' => 'musics#show'
  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}

  #comfy_route :cms_admin, :path => '/admin'
  #comfy_route :cms, :path => '/', :sitemap => false

  get '/:id' => 'users#show'
end
