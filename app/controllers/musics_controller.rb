class MusicsController < ApplicationController
  def show
    @music = Music.find(params[:id]) 
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
