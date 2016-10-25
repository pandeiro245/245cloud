class Api::WorkloadsController < ApplicationController
  def index
    type = params[:type]
    limit = params[:limit] || 48
    scope = Workload.of_type(type)
    id = params[:facebook_id]
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
    workload = Workload.his(
      current_user.facebook_id
    ).created.first.to_done!
    render json: workload.decorate
  end

  def create
    workload = Workload.create_with_issue!(
      current_user, params
    )
    render json: workload.decorate
  end
end

