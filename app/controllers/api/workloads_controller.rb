class Api::WorkloadsController < ApplicationController
  def index
    type = params[:type]
    limit = params[:limit] || 48
    scope = Workload.of_type(type)
    scope = scope.his(params[:facebook_id]).dones if params[:facebook_id]
    scope = scope.limit(limit) if scope.limit_value.nil?
    scope = (params[:best] ? scope.bests : scope.created).decorate.reverse
    render json: scope
  end

  def complete # PUT update にする
    render json: Workload.his(
      current_user.facebook_id
    ).created.first.to_done!.decorate
  end

  def create
    workload = Workload.create!(
      facebook_id: current_user.facebook_id,
      music_key: params['music_key'].presence,
      title: params['title'].presence,
      artwork_url: params['artwork_url'].presence
    ).decorate
    render json: workload
  end
end

