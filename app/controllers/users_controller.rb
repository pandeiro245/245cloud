class UsersController < ApplicationController
  def index
    @users = Workload.group(:user_id).count.to_a.sort_by{|u| u.last}.reverse
  end

  def show
    @user = User.find_by(
      id: params[:id]
    )
  end

  def login_with_token
    token = params[:token]
    user_id = params[:user_id]
    user = User.find_by(
      id: user_id,
      token: token
    )
    raise 'invalid token' if user.blank?
    user
    sign_in(user)
    redirect_to '/'
  end

  def login
    provider = params[:provider]
    case provider
    # when 'facebook'
    #   login_with_facebook
    when 'twitter'
      login_with_twitter
    else
      _login(provider)
    end
    redirect_to '/'
  end

  def login_with_twitter
    auth_hash = request.env['omniauth.auth']
    twitter_id = auth_hash['uid'].to_i
    user = current_user
    user ||= User.find_by(
      twitter_id: twitter_id
    )
    if user.nil?
      user = User.new(
        email: "tw-#{twitter_id}@245cloud.com"
      )
      user.save!
      user.email = "#{user.id}@245cloud.com"
    end
    user.twitter_id ||= twitter_id
    user.save!
    `wget -O public/images/profile/#{user.id}.jpg #{auth_hash[:info][:image]}`
    sign_in(user)
  end

  # def login_with_facebook
  #   auth_hash = request.env['omniauth.auth']
  #   facebook_id = auth_hash['uid'].to_i
  #   user = User.find_by(
  #     facebook_id: facebook_id
  #   )
  #   if user.nil?
  #     user = User.new(
  #       email: "fa-#{facebook_id}@245cloud.com",
  #       facebook_id: facebook_id
  #     )
  #     user.save!
  #     user.email = "#{user.id}@245cloud.com"
  #     user.save!
  #   end
  #   sign_in(user)
  # end

  def _login provider
    auth_hash = request.env['omniauth.auth']
    keys = {}
    %w(expires_at refresh_token token secret).each do |key|
      val = auth_hash.credentials.send(key)
      keys["#{provider}_#{key}"] = val
    end
    cookies[provider] = keys.to_json
    if provider.to_s == 'discord' && current_user.present?
      current_user.discord_id = auth_hash['uid']
      current_user.save!
    end
    redirect_to "/?#{provider}=1", notice: 'Signed in successfully'
  end
end

