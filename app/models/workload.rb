class Workload < ActiveRecord::Base
  # status 
  # 0: created (playing or expired)
  # 1: done
  # 2: canceled
  belongs_to :user
  belongs_to :music
  scope :dones, -> { where(status: 1) }
  scope :playings, -> { where(status: 0, created_at: Time.now..(Time.now - Workload.pomominutes)) }
  scope :chattings, -> { where(status: 1, created_at: (Time.now - Workload.pomominutes)..(Time.now - 5.minutes)) }

  def self.pomotime
    Settings.pomotime
  end

  def self.pomominutes
    self.pomotime.minutes
  end

  def icon
    user.present? ? user.icon : "https://ruffnote.com/attachments/24311"
  end

  def music_icon
    if music.present?
      if music.icon.present?
        return music.icon
      else
        id = 24162
      end
    else
      id = 24981 
    end  
    return "https://ruffnote.com/attachments/#{id}"
  end

  def title
    music.present? ? music.title : '無音'
  end

  def key
    return nil unless music
    music.key_old
  end

  def complete!
    self.status = 1
    self.number = Workload.where(user_id: self.user_id, status: 1, created_at: Time.now.midnight..Time.now).count + 1
    self.save!
  end

  def cancel!
    if playing?
      self.status = 2
    elsif done?
      self.status = 3
    end
    self.save!
  end

  def playing?
    status == 0 && Time.now < created_at + Workload.pomotime.minutes + 6.minutes
  end

  def expired?
    Time.now > created_at + Workload.pomotime.minutes + 6.minutes
  end

  def done?
    status == 1 || (!playing && !expired)
  end

  def self.playings
    Workload.where(
      created_at: (Time.now - Workload.pomotime.minutes)..Time.now
    ).where(
      status: 0
    ).order('id desc')
  end

  def self.chattings
    pomo = Time.now - Workload.pomotime.minutes
    Workload.where(
      created_at: (pomo - 5.minutes)..pomo
    ).where(
      status: 1
    ).order('id desc')
  end

  def self.dones limit = 48
    Workload.where(
      status: 1
    ).order('id desc').limit(limit)
  end

  def self.refresh_numbers
    numbers = {}
    Workload.where(number: nil).dones.order('id asc').each do |workload|
      numbers[workload.user_id] ||= {}

      date   = workload.created_at.to_date.to_s
      previous_date = numbers[workload.user_id][:date]

      previous_number = numbers[workload.user_id][:number]

      if date == previous_date
        workload.number = previous_number + 1
      else
        workload.number = 1
      end
      numbers[workload.user_id] = {date: date, number: workload.number}
      workload.save!
    end
    puts 'done'
  end

  def self.sync is_all = false
    data = ParsecomWorkload.where(workload_id: nil).sort{|a, b| 
      a.attributes['createdAt'].to_time <=> b.attributes['createdAt'].to_time
    }
    if !is_all && !Workload.count.zero?
      from = Workload.last.created_at.to_time
      data.select!{|w| w['createdAt'].to_time > from}
    end

    data.each do |u|
      attrs = u.attributes
      instance = Workload.find_or_initialize_by(
        parsecomhash: attrs['objectId']
      )
      instance.status  = attrs['is_done']
      begin
      instance.user_id = User.find_by(
        parsecomhash: attrs['user']['objectId']
      ).id
      rescue
        # 初期のWorkloadはuserカラムがなくTwitterカラムだった
      end
      instance.save!
      u.workload_id = instance.id
      u.save
    end
  end
end

