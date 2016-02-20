class Api::WorkloadsController < ApplicationController
  def index
    type = params[:type]
    scope = Workload.of_type(type)
    scope = scope.his_dones(params[:facebook_id]) if fid = params[:facebook_id]
    scope = scope.limit(48) if scope.limit_value.nil?
    scope = (params[:best] ? scope.bests : scope.created).decorate.reverse
    render json: scope
  end

  def complete # PUT update にする
    workload = Workload.where(
      facebook_id: current_user.facebook_id
    ).order('created_at desc').first
    #if workload.created_at + Workload.pomotime <= Time.now
    if true
      workload.number = workload.next_number
      workload.is_done = true
      workload.save!
    end
    render json: workload.decorate
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

