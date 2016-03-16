class Api::ServersController < ApplicationController
  def index
    render json: Server.all
  end
end
