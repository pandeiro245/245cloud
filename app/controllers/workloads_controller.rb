class WorkloadsController < ApplicationController
  def dones
    render json: Workload.where(is_done: true).limit(48).map{|w|
      hash = JSON.parse(w.to_json)
      hash['created_at'] = w.created_at.to_i * 1000 # JSはマイクロ秒
      hash
    }
  end
end
