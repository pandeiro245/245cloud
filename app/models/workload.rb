class Workload < ActiveRecord::Base
  # status 
  # 0: created (playing or expired)
  # 1: done
  # 2: canceled
  belongs_to :user
  belongs_to :music
  scope :dones, -> { where(status: 1) }

  def self.pomotime
    Settings.pomotime
    24
  end

  def complete!
    self.status = 1
    self.save!
  end

  def cancel!
    self.status = 2
    self.save!
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
    self.number = Workload.where(user_id: self.user_id, status: 1).count + 1
    self.save!
  end

  def self.playings
    Workload.where(
      created_at: (Time.now - Workload.pomotime.minutes)..Time.now
    ).where(
      status: 0
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

  def key
    return nil unless music
    music.key_old
  end
end

