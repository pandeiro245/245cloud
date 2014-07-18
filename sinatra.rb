require 'sinatra'
require 'net/http'
require 'uri'
require 'omniauth-twitter'

configure do
  set :sessions, true
  set :inline_templates, true
  set :session_secret, ENV['SESSIONSECRET']
end

get '/aaa' do
  raise ENV.inspect
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

use OmniAuth::Builder do
  # http://qiita.com/tomomomo1217/items/77c9b64266daf6315abe
  provider :twitter, ENV['TWITTERKEY'], ENV['TWITTERSECRET']
end

# https://gist.github.com/fairchild/1442227
get '/auth/:provider/callback' do
  data = request.env['omniauth.auth']
  twitter_id = data[:uid]
  erb "
    少々お待ちください
    <script src=\"http://www.parsecdn.com/js/parse-1.2.18.min.js\"></script>
    <script>
    Parse.initialize(\"8QzCMkUbx7TyEApZjDRlhpLQ2OUj0sQWTnkEExod\", \"gzlnFfIOoLFQzQ08bU4mxkhAHcSqEok3rox0PBOM\")
    var Twitter = Parse.Object.extend(\"Twitter\");
    var twitter = new Twitter();
    twitter.set('twitter_id', #{twitter_id})
    twitter.set('twitter_nickname', '#{data[:info][:nickname]}')
    twitter.set('twitter_image', '#{data[:info][:image]}')
    twitter.save(null, {
      success: function(data){
        localStorage['twitter_id'] = data.attributes.twitter_id
        localStorage['twitter_nickname'] = data.attributes.twitter_nickname
        localStorage['twitter_image'] = data.attributes.twitter_image
        location.href = '/'
      },
      error: function(twitter, error){
        console.log(error);
      }
    })
    </script>
  "
end
