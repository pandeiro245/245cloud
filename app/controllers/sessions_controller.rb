class SessionsController < ApplicationController
  def callback
    data = request.env['omniauth.auth']
    auth = Auth.find_or_create_with_omniauth(data)
    auth.register!
    redirect_to root_path, notice: 'ログインが完了しました'
  end

  def failure
    redirect_to (user_signed_in? ? :auths : :root), alert: I18n.t('flash.sessions.fail')
  end
end


