class HomeController < ApplicationController
  def index
    if current_user.present? && current_user.status == 'chatting'
      current_user.chatting.to_done!
    end
  end

  def redirect
    redirect_to params[:url]
  end
end

