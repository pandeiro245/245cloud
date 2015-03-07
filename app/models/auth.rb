class Auth < ActiveRecord::Base
  belongs_to :user
  scope :facebook, -> { where(provider: 'facebook') }

  def self.create_with_omniauth(data)
    auth = Auth.find_or_initialize_by(
      provider: data['provider'],
      uid:      data['uid']
    )
    auth.set_info(data)
    auth.save
    auth
  end
  
  def set_info(data)
    unless data['info'].blank?
      self.name = data['info']['name']
      self.nickname = data['info']['nickname']
      self.image = data['info']['image']
    end
    self.token = data.try(:[], 'credentials').try(:[], 'token')
    self.credentials = data.try(:[], 'credentials')
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

