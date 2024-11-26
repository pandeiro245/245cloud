class MusicsController < ApplicationController
  def index
    provider = params[:provider]
    key = URI.encode_www_form_component(params[:key])
    key = "#{key}/#{URI.encode_www_form_component(params[:key2])}/" if params[:key2] # mixcloud
    @music = Music.new_from_key(provider, key)
    @music.save!
    @music.fetch if @music.artwork_url.blank?
  end
end
