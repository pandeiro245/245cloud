class Workload < ActiveRecord::Base
  def self.pomotime
    1.seconds # 24.minutes
  end

  def self.sync(skip=0)
    ParsecomWorkload.sync(skip)
  end

  def self.yours user, limit=48
    Workload.where(
      is_done: true,
      facebook_id: user.facebook_id
    ).limit(limit).order('created_at desc')
  end

  def self.dones limit=48
    Workload.where(is_done: true).limit(limit).order('created_at desc')
  end

  def next_number
    Workload.where(
      facebook_id: facebook_id,
      created_at: Date.today.beginning_of_day..Time.now,
      is_done: true
    ).count + 1
  end
end
