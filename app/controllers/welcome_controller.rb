class WelcomeController < ApplicationController
  def index
    if current_user && current_user.playing?
      redirect_to current_user.workload
    end
    @musics_users = MusicsUser.limit(3).order('total desc')
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path
  end
end

