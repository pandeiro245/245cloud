class RoomsController < ApplicationController
  def index
    render json: Room.all
  end
end
