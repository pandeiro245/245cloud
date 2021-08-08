class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def status
    return 'playing' if Workload.playings.where(user_id: id).present?
    return 'chatting' if Workload.chattings.where(user_id: id).present?
    return 'before'
  end

  def url
    refresh_token! if token.blank?
    "https://245cloud.com/login?user_id=#{id}&token=#{token}"
  end

  def refresh_token!
    self.token = SecureRandom.hex(64)
    self.save!
  end

  def workloads
    Workload.his(id).bests.limit(48)
  end

  def start!(params={})
    Workload.find_or_start_by_user(self, params)
  end

  def to_done!
    w = Workload.his(
      id
    ).chattings.first
    w.to_done! if w.present?
    w
  end

  def email_required?
    false
  end

  def password_required?
    false
  end
end

