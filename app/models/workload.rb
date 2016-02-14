class Workload < ActiveRecord::Base
  def self.pomotime
    24.minutes
  end

  def self.chattime
    5.minutes
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

  def self.playings
    limit = 200
    from = Time.now - self.pomotime
    to   = Time.now
    Workload.where(
      created_at: from..to,
    ).limit(limit).order('created_at desc')
  end

  def self.chattings
    limit = 200
    from = Time.now - self.pomotime - self.chattime
    to   = Time.now-self.pomotime
    Workload.where(
      is_done: true,
      created_at: from..to,
    ).limit(limit).order('created_at desc')
  end


  def self.dones limit=48
    Workload.where(is_done: true).limit(limit).order('created_at desc')
  end

  def next_number
    # 暫定対応 refs #226
    now = Time.now
    from = now - now.hour.hours - now.min.minutes - now.sec.seconds

    puts from.to_s
    Workload.where(
      facebook_id: facebook_id,
      created_at: from..Time.now,
      is_done: true
    ).count + 1
  end
end
