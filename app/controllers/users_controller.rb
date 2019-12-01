class UsersController < ApplicationController
  def show
    @user = User.find_or_create_by(
      facebook_id: params[:id]
    )
  end

  def login
    provider = params[:provider]
    if provider == 'facebook'
      login_with_facebook
    else
      _login(provider)
    end
  end

  def login_with_facebook
    auth_hash = request.env['omniauth.auth']
    facebook_id = auth_hash['uid'].to_i
    user = User.find_by(
      facebook_id: facebook_id
    )
    if user.nil?
      user = User.new(
        email: "fa-#{facebook_id}@245cloud.com",
        facebook_id: facebook_id
      )
      user.save!
      user.email = "#{user.id}@245cloud.com"
      user.save!
    end
    sign_in(user)
    redirect_to '/'
  end

  def _login provider
    auth_hash = request.env['omniauth.auth']
    keys = {}
    %w(expires_at refresh_token token secret).each do |key|
      val = auth_hash.credentials.send(key)
      keys["#{provider}_#{key}"] = val
    end
    cookies[provider] = keys.to_json
    if current_user.present?
      a = current_user.provider_user(provider)
      a.key = auth_hash['uid']
      a.save!
    end
    redirect_to "/?#{provider}=1", notice: 'Signed in successfully'
  end
end

