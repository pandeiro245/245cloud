class Workload < ActiveRecord::Base
  belongs_to :user
  belongs_to :music
  scope :dones, -> { where(is_done: true) }

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
    @workload.is_done = true
    @workload.number = Workload.where(is_done: true).count + 1 # FIXME
    @workload.save!
    @workload
  end

  def self.playings
    Workload.where(
      created_at: (Time.now - 24.minutes)..Time.now
    ).order('id desc')
  end

  def self.dones limit = 48
    Workload.where(
      is_done: true 
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

