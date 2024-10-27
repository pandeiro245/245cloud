class MusicsController < ApplicationController
  def index
    provider = params[:provider]
    key = params[:key]
    key = "/#{key}/#{params[:key2]}/" if params[:key2] # mixcloud
    key = URI.encode_www_form_component(key)
    @music = Music.new_from_key(provider, key)
  end
end
