class WorkloadsController < ApplicationController
  def doings
  end

  def chattings
  end

  def dones
    @workloads = Workload.limit(48).map do |workload| 
      w = JSON.parse(workload.to_json)
      w['icon_url'] = workload.icon_url
      w
    end
    render json: @workloads.to_json
  end

  def create
    Workload.create!
    render json: 'ok'
  end

  def update
    #TODO
    # is_doneをtrueにする
    # number（その日何回目のポモか）を保存
  end
end

