class MusicsController < ApplicationController
  def show
    @music = Music.find(params[:id]) 
  end

  def random
  end
end
