class Api::WorkloadsController < ApplicationController
  def index
    workloads = Workload.dones
    if fid = params[:facebook_id]
      workloads = Workload.his_dones(fid)
    elsif type = params[:type]
      case type
      when 'playing'
        workloads = Workload.playings
      when 'chatting'
        workloads = Workload.chattings
      else
        workloads = Workload.dones
      end
    else
      workloads = Workload.dones
    end
    if params[:best]
      #workloads = workloads.bests.limit(999)
      workloads = Workload.his_dones(fid).bests.limit(999)
    end
    render json: workloads.decorate
  end

  def complete # PUT update にする
    workload = Workload.where(facebook_id: current_user.facebook_id).order('created_at desc').first
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

