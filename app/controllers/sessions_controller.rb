class SessionsController < ApplicationController
  def callback
    data = request.env['omniauth.auth']
    session[:user_id] = User.login(data).id
    redirect_to root_path, notice: 'ログインが完了しました'
  end

  def failure
    redirect_to (user_signed_in? ? :auths : :root), alert: I18n.t('flash.sessions.fail')
  end
end


