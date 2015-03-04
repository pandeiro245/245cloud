class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def callback
    data = request.env['omniauth.auth']
    raise data.inspect
  end

  def failure
    redirect_to (user_signed_in? ? :auths : :root), alert: I18n.t('flash.sessions.fail')
  end
end


