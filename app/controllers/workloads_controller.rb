class WorkloadsController < ApplicationController
  def doings
    render json: Workload.doings
  end

  def chattings
  end

  def dones
    render json: Workload.dones
  end

  def create
    render json: Workload.create! # user_id is nilを許容
  end

  def complete
    render json: Workload.find(params[:id]).complete!
  end
end

