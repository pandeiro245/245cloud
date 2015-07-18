class PrefsController < ApplicationController
  def show
    @pref = Pref.find(params[:id])
  end
end
