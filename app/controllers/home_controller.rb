class HomeController < ApplicationController
  def index
    if params[:music_provider].present?
      @music = Music.new_from_key(params[:music_provider], params[:music_key])
    end

    current_user.done = true if params[:done].to_i == 1

    if current_user.present? && current_user.status == 'chatting'
      current_user.chatting.to_done!
    end
  end

  def redirect
    redirect_to params[:url]
  end
end

