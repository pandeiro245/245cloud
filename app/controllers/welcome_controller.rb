class WelcomeController < ApplicationController
  def index
  end

  def sign_out
    sign_out
    # sign_out(current_user)
    redirect_to '/'
  end

  def redirect
    redirect_to params[:url]
  end
end

