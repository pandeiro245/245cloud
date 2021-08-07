class WelcomeController < ApplicationController
  def index
    # sign_out(current_user)
  end

  def redirect
    redirect_to params[:url]
  end
end

