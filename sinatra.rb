require 'sinatra'
require 'net/http'
require 'uri'
require 'dotenv'
require 'omniauth-twitter'
require 'coffee-script'

Dotenv.load

get "/:filename.js" do
  coffee params[:filename].to_sym
end

get '/' do
  File.open 'public/index.html'
end

get '/proxy' do
  raise 'forbidden' unless params[:url].match(/^https:\/\/ruffnote.com\/pandeiro245\/245cloud\/[0-9]*\/download.json$/)
  headers "Content-Type" => "text/json; charset=utf8"
  url = params[:url]
  Net::HTTP.get(URI.parse(url))
end
