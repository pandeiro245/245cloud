class WorkloadsController < ApplicationController
  def doings
    render json: Workload.doings
  end

  def chattings
    render json: Workload.chattings
  end

  def dones
    user_id = params[:user_id] || nil
    render json: Workload.dones(user_id)
  end
end
