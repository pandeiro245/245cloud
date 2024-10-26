class Api::WorkloadsController < ApplicationController
  def index
    type = params[:type]
    limit = params[:limit] || 48
    scope = Workload.of_type(type)
    id = params[:user_id]
    scope = scope.his(id).dones if id 
    scope = scope.limit(limit) if scope.limit_value.nil?
    if params[:best]
      scope = scope.bests
    elsif params[:weekly_ranking]
      scope = scope.weekly_ranking
    else
      scope = scope.created
    end
    scope = scope.decorate.reverse
    render json: scope
  end

  def complete # TODO: PUT update にする
    render json: current_user.to_done!.decorate
  end

  def create
    workload = current_user.start!(params).decorate
    redirect_to :root
  end
end

