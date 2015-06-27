class WorkloadsController < ApplicationController
  def show
    @workload = Workload.find(params[:id])
    @remain = (@workload.created_at + Workload.pomotime.minutes - Time.now).to_i

    if @remain < 0 # 24分以上経過
      if @remain > - 60 * 6 # 経過時間30分未満
        current_user.workload.complete! if current_user.workload
      end
      redirect_to '/'
    end
  end

  def new
    if current_user.playing?
      redirect_to '/'
    else
      workload = Workload.new(user: current_user)
      workload.music_id = params[:music_id] if params[:music_id]
      workload.save!
      redirect_to workload
    end
  end

  def cancel
    workload = current_user.workload
    if workload.playing?
      workload.cancel!
    elsif workload.done?
      session[:done_workload_without_chatting_id] = workload.id
    end
    redirect_to '/'
  end
end

