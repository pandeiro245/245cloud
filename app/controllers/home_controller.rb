class HomeController < ApplicationController
  def index
    @music = Music.new_from_key(params[:music_provider], params[:music_key]) if params[:music_provider].present?
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

