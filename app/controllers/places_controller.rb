class PlacesController < ApplicationController
  def index
    @type = params[:year] || nil 
  end 

  def show
    @place = Place.find(params[:id])
  end
end
