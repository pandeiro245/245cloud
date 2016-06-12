class WelcomeController < ApplicationController
  def index
    is_redirect = false
    [:alert, :timecrowd, :twitter].each do |sym|
      if params[sym]
        cookies[:settings] = Setting.set cookies, sym
        is_redirect = true
      end
    end
    if params[:cancel]
      cookies[:settings] = Setting.del cookies, params[:cancel]
      is_redirect = true
    end
    redirect_to :root if is_redirect
  end
end

