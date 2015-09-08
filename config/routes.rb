Rails.application.routes.draw do
  get '/musics/:id' => 'musics#show'
  root 'welcome#index'
  resources :nicoinfo, only: [:show], constraints: {id: /sm[0-9]+/}

  #comfy_route :cms_admin, :path => '/admin'
  #comfy_route :cms, :path => '/', :sitemap => false

  get '/:id' => 'users#show'
end
