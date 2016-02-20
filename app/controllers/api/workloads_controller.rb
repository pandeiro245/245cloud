class Api::WorkloadsController < ApplicationController
  def complete
    workload = Workload.where(facebook_id: current_user.facebook_id).order('created_at desc').first
    #if workload.created_at + Workload.pomotime <= Time.now
    if true
      workload.number = workload.next_number
      workload.is_done = true
      workload.save!
    end
    render json: workload.decorate
  end

  def chattings
    render json: Workload.chattings
  end

  def playings
    render json: Workload.playings
  end

  def dones
    limit = params[:limit] || 48
    render json: Workload.dones(limit)
  end

  def yours
    limit = params[:limit] || 48
    render json: Workload.yours(current_user, limit)
  end

  def your_bests
    limit = params[:limit] || 48
    render json: Workload.your_bests(current_user, limit)
  end

  def create
    workload = Workload.create!(
      facebook_id: current_user.facebook_id,
      music_key: params['music_key'].presence,
      title: params['title'].presence,
      artwork_url: params['artwork_url'].presence
    )
    workload = JSON.parse(workload.to_json)
    workload['created_at'] = workload['created_at'].to_i * 1000
    render json: workload
  end
end

