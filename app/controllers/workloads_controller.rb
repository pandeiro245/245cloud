class WorkloadsController < ApplicationController
  def show
    @workload = Workload.find(params[:id])
    @remain = (@workload.created_at + Workload.pomotime.minutes - Time.now).to_i

    if @remain < 0 # 24分以上経過
      if @remain > - 60 * 6 # 経過時間30分未満
        @workload.complete!
        is_room = true
      end
      redirect_to (is_room ? room_path(Room.first) : root_path)
    end
  end

  def new
    workload = Workload.new(user: current_user)
    workload.music_id = params[:music_id] if params[:music_id]
    workload.save!
    redirect_to workload
  end

  def cancel
    workload = current_user.workload
    if workload.playing?
      workload.cancel!
    end
    redirect_to '/'
  end
end

