class HomeController < ApplicationController
  def index
    if params[:music_provider].present?
      store_music_session(params[:music_provider], params[:music_key])
      redirect_to music_path, allow_other_host: false
    else
      load_music_from_session
    end
    @musics = Music.search(params[:search_word]) if params[:search_word].present?
  end

  def playing
    case current_user.status
    when 'playing'
      # do nothing
    when 'chatting'
      current_user.chatting.to_done!
      redirect_to chatting_path
    else
      redirect_to root_path
    end
  end

  def chatting
    hash = {}
    redirect_to root_path(hash) unless current_user.status == 'chatting'
  end

  def redirect
    redirect_to params[:url]
  end
end

