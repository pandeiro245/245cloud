class HomeController < ApplicationController
  def index
    if current_user.present? && current_user.status == 'chatting'
      current_user.chatting.to_done!
    end
  end
end

