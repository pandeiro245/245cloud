class Api::WorkloadsController < ApplicationController
  def complete
    workload = Workload.where(facebook_id: current_user.facebook_id).order('created_at desc').first
    if workload.created_at + Workload.pomotime <= Time.now
      workload.number = workload.next_number
      workload.is_done = true
      workload.save!
    end
    render json: workload
  end

  def dones
    render json: Workload.dones.map{|w|
      hash = JSON.parse(w.to_json)
      hash['created_at'] = w.created_at.to_i * 1000 # JSはマイクロ秒
      hash
    }
  end

  def yours
    render json: Workload.yours(current_user).map{|w|
      hash = JSON.parse(w.to_json)
      hash['created_at'] = w.created_at.to_i * 1000 # JSはマイクロ秒
      hash
    }
  end

  def create
    workload = Workload.create(
      facebook_id: current_user.facebook_id,
    )
    if workload
      workload = JSON.parse(workload.to_json)
      workload['created_at'] = workload['created_at'].to_i * 1000
    end
    render json: workload
  end
end

