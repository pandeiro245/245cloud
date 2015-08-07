class Workload < ActiveRecord::Base
  belongs_to :user
  belongs_to :music
  scope :playings, -> { where(status: 0, created_at: (Time.now - Workload.pomominutes)..Time.now) }
  scope :chattings, -> { where(status: 1, created_at: (Time.now - Workload.pomominutes - 5.minutes)..(Time.now - Workload.pomominutes)) }

  def self.pomotime
    Settings.pomotime
    0.1
  end

  def self.pomominutes
    self.pomotime.minutes
  end

  def save_with_parsecom!
    parse_user = ParsecomUser.find(user.parsecomhash)
    if self.parsecomhash
      parse_workload = ParsecomWorkload.find(self.parsecomhash)
    else
      parse_workload = ParsecomWorkload.new(user: parse_user)
    end
    if music_id
      key_val = self.music.key.split(':')
      key = key_val.first
      val = key_val.last
      parse_workload.send("#{key}_id=", val)
      parse_workload.title = music.title
      parse_workload.artwork_url = music.icon
    end
    if self.status == 1
      parse_workload.is_done = true
    end
    if self.number
      parse_workload.number = self.number
    end
    if parse_workload.save
      save!
    else
      raise parse_workload.inspect
    end
  end

  def chatting?
    created_at + Workload.pomominutes < Time.now && Time.now < created_at + Workload.pomominutes + 5.minutes
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
    #self.save!
    self.save_with_parsecom!
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

  def self.dones_count
    self.dones(nil).count
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
      data.select!{|w| w.attributes['createdAt'].to_time > from}
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
      instance.created_at = attrs['createdAt'].to_time
      instance.save!
      u.workload_id = instance.id
      u.save
    end
  end
end

