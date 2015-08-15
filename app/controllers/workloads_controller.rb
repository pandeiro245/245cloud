class WorkloadsController < ApplicationController
  def show
    @workload = Rails.cache.fetch("workload:#{params[:id]}") do
      Workload.find(params[:id])
    end
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
    workload.save_with_parsecom!

    Rails.cache.fetch("workload:#{workload.id}") do
      workload
    end
    redirect_to workload
  end
end

