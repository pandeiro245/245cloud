class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def email_required?
    false
  end

  def password_required?
    false
  end

  def new_parsecom_password
    ParsecomUser.update_password(
      facebook_id
    )
  end
end

