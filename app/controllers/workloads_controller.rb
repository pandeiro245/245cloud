class WorkloadsController < ApplicationController
  def show
    @workload = Workload.find(params[:id])
    @remain = (@workload.created_at + 24.minutes - Time.now).to_i
  end

  def new
    if current_user.playing?
      redirect_to '/'
    else
      workload = Workload.create!(user: current_user)
      redirect_to workload
    end
  end

  def cancel
    current_user.workload.cancel!
    redirect_to '/'
  end

  def complete
    current_user.workload.complete!
    redirect_to '/'
  end
end

