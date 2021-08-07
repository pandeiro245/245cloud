class WelcomeController < ApplicationController
  def index
  end

  def redirect
    redirect_to params[:url]
  end
end

