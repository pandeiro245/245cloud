class MusicsController < ApplicationController
  include ApplicationHelper
  def show
    @music = Rails.cache.fetch("music:#{params[:id]}") do
      Music.find(params[:id])
    end
    if !@music.title || params[:nocache] # TODO 無限ループ対策
      @music.fetch
      Rails.cache.delete("music:#{params[:id]}")
      Rails.cache.fetch("music:#{params[:id]}") do
        @music
      end
    end
  end

  def index
    if key = params[:key]
      redirect_path = music_path(
        Music.find_or_create_by(
          key: key
        )
      )
    else
      redirect_path = root_path 
    end
    redirect_to redirect_path
  end

  def random
    musics = Music.where(total_count: 10..10000000) #FIXME
    music_id = params[:music_id] || nil
    music_id = music_id.to_i
    music = musics[(musics.count * rand).to_i]
    while music.id == music_id
      music = musics[(musics.count * rand).to_i]
    end
    redirect_to "/musics/#{music.id}"
  end
end
