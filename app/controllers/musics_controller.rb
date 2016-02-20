class MusicsController < ApplicationController
  def index
    key = params[:key]
    key = "/#{key}/#{params[:key2]}/" if params[:key2]
    key = URI.encode(key)
    key = "#{params[:provider]}:#{key}"
    @music = Music.new(key)
  end
end
