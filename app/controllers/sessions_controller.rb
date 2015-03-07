class SessionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token

  def callback
    data = request.env['omniauth.auth']
    auth = Auth.find_by(
      provider: data['provider'],
      uid:      data['uid']
    ).presence || Auth.create_with_omniauth(data)

    if user_signed_in?
      #TODO: UserとAuthを紐づける
    else
      #TODO: 新規Userとして登録
      auth.register! unless auth.user.present?
    end
    redirect_to root_path, notice: 'ログインが完了しました'
  end

  def failure
    redirect_to (user_signed_in? ? :auths : :root), alert: I18n.t('flash.sessions.fail')
  end
end


