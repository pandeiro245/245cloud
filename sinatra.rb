require 'sinatra'
require 'coffee-script'

get "/:filename.js" do
  coffee params[:filename].to_sym
end

get '/' do
  File.open 'public/index.html'
end
