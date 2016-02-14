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

  def self.sync
    ParsecomUser.all.each do |u|
      self.find_or_create_by(
        facebook_id: u['facebook_id_str']
      )
    end
    puts 'done'
  end
end

