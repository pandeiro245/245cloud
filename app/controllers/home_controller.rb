class HomeController < ApplicationController
  def index
    if params[:music_provider].present?
      key = "#{params[:music_provider]}:#{params[:music_key]}"
      @music = Music.new(key)
    end

    if current_user.present? && current_user.status == 'chatting'
      current_user.chatting.to_done!
    end
  end

  def redirect
    redirect_to params[:url]
  end
end

