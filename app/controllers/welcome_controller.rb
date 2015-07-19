class WelcomeController < ApplicationController
  def index
    #raise cookies['timecrowd'].inspect
    @dones = Workload.dones
    @musics_users = MusicsUser.limit(3).order('total desc')
    render layout: 'top'
    if current_user && current_user.playing?
      @resume_minutes = ((current_user.workload.created_at + Workload.pomotime.minutes - Time.now)/60).to_i
    end
    @dc = Workload.dones_count
    @uc = User.count
    @dc_per_user = @uc.zero? ? 0 : (@dc/@uc).to_i
  end

  def pitch
    render layout: 'top'
  end

  def logout
    session[:user_id] = nil
    redirect_to root_path
  end
end

