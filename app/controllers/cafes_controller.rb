class CafesController < ApplicationController
  def index
    @type = params[:year] || nil 
  end 

  def show
    @cafe = Cafe.find(params[:id])
  end
end
