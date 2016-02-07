class TogglController < ApplicationController
  def stop
    Toggl.new(params[:token]).stop
    render json: 'ok'
  end

  def start
    Toggl.new(params[:token]).start
    render json: 'ok'
  end
end
