class Api::WorkloadsController < ApplicationController
  def download
    if params[:page].present?
      page = params[:page].to_i
      from = ((page - 1) * 1000) + 1
      to   = from + 999
      range = from.upto(to).to_a
      workloads = Workload.where(id: range)
    else
      workloads = Workload.order('id desc').limit(1000)
    end
    render json: workloads.to_json
  end

  def index
    type = params[:type]
    limit = params[:limit] || 48
    scope = Workload.of_type(type)
    id = params[:user_id]
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
    render json: current_user.to_done!.decorate
  end

  def create
    workload = current_user.start!(params).decorate
    redirect_params = {}

    if params[:music_key].present?
      redirect_params[:music_key] = params[:music_key]
      redirect_params[:music_provider] = params[:music_provider]
      session[:music_provider] = params[:music_provider]
      session[:music_key] = params[:music_key]
    end
    redirect_to playing_path(redirect_params)
  end
end

