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
    render json: scope.map{|w| w.artwork_url = "data:image/png;base64,#{w.music.icon}" if w.music; w}
  end

  def complete # TODO: PUT update にする
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

