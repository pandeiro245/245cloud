class WorkloadsController < ApplicationController
  def new
    unless current_user.playing?
      Workload.create!(user: current_user)
    end
    redirect_to '/'
  end

  def complete
    render json: Workload.find(params[:id]).complete!
  end
end

