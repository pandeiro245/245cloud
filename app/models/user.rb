class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def workloads
    Workload.his(facebook_id).bests.limit(48)
  end

  def start!
    Workload.find_or_start_by_user(self)
  end

  def email_required?
    false
  end

  def password_required?
    false
  end
end

