class WelcomeController < ApplicationController
  def index
    if current_user && current_user.playing?
      redirect_to current_user.workload
    elsif current_user && current_user.chatting_workload
      redirect_to "/rooms/0"
    else
      @dones = Workload.dones
      @yous = current_user.workloads
      @musics_users = MusicsUser.limit(3).order('total desc')
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path
  end
end

