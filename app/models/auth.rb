class Auth < ActiveRecord::Base
  belongs_to :user

  def self.find_or_create_with_omniauth(data)
    auth = Auth.find_or_create_by(
      provider: data['provider'],
      uid:      data['uid']
    )
    auth.set_info(data)
    auth.save!
    unless auth.user_id
      user = User.create!
      auth.user_id = user.id
      auth.save!
    end
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
      )
      user.save!
    end
  end
end

