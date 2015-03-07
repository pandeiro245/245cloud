class Auth < ActiveRecord::Base
  belongs_to :user

  def self.find_or_create_with_omniauth(data)
    auth = Auth.find_or_create_by(
      provider: data['provider'],
      uid:      data['uid']
    )
    auth.set_info(data)
    auth.save!
    auth
  end
  
  def set_info(data)
    unless data['info'].blank?
      self.name = data['info']['name']
      self.nickname = data['info']['nickname']
      self.image = data['info']['image']
    end
  end

  def register!
    ActiveRecord::Base.transaction do
      user = User.new(
        email: "#{self.provider}-#{self.uid}@245cloud.com", # 個人サービスなのでメールアドレスは取得しない
        password: Devise.friendly_token[0, 20]
      )
      user.skip_confirmation!
      user.skip_confirmation_notification!
      user.save!

      self.user = user
      save!
    end
  end
end

