class MusicsController < ApplicationController
  def index
    provider = params[:provider]
    key = params[:key]
    key = "/#{key}/#{params[:key2]}/" if params[:key2] # mixcloud
    key = URI.encode_www_form_component(key)
    key = "#{provider}:#{key}"
    @music = Music.new(key)
  end
end
