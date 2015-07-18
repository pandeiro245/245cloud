class CafesController < ApplicationController
  def index
    @type = params[:year] || nil 
  end 
end
