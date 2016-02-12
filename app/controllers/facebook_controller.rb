class FacebookController < ApplicationController
  def login
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
    redirect_to :root
  end
end

