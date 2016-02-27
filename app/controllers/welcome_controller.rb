class WelcomeController < ApplicationController
  def index
<<<<<<< HEAD
    is_redirect = false
    [:alert, :timecrowd].each do |sym|
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
=======
>>>>>>> parse.com系のファイルをがっつり削除
  end
end

