class WorkloadsController < ApplicationController
  def doings
    @workloads = Workload.where(
      "created_at > '#{(Time.now - 24.minutes).to_s}'"
    ).order('id desc').limit(96).map do |workload| 
      w = JSON.parse(workload.to_json)
      w['icon_url'] = workload.icon_url
      w
    end
    render json: @workloads.to_json
  end

  def chattings
  end

  def dones
    @workloads = Workload.where(
      "created_at < '#{(Time.now - 24.minutes).to_s}'" # 不要？
    ).where(
      is_done: true 
    ).order('id desc').limit(48).map do |workload| 
      w = JSON.parse(workload.to_json)
      w['icon_url'] = workload.icon
      if workload.music
        w['artwork_url'] = workload.music.icon
        w['title']       = workload.music.title
      end
      w
    end
    render json: @workloads.to_json
  end

  def create
    workload = Workload.create!
    render json: workload
  end

  def complete
    @workload = Workload.find(params[:id])
    @workload.is_done = true
    @workload.number = Workload.where(is_done: true).count + 1 # FIXME
    @workload.save!
    render json: "id: #{@workload.id} is completed."
  end
end

