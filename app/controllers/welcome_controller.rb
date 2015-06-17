class WelcomeController < ApplicationController
  def index
    @musics_users = MusicsUser.limit(3).order('total desc')
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path
  end
end

