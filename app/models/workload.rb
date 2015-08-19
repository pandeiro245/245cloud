#class Workload < ActiveRecord::Base
class Workload
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status, type: Integer
  field :key, type: String
  field :music_id, type: Integer
  field :number, type: Integer
  #field :user_id, type: Integer
  field :user_hash, type: String
  field :parsecomhash, type: String
  field :place_id, type: Integer

  belongs_to :user
  belongs_to :music

  include Redis::Objects
  value :hoge

  def self.pomotime
    Settings.pomotime
  end

  def self.chattime
    Settings.chattime
    5
  end

  def self.pomominutes
    self.pomotime.minutes
  end

  def self.chatminutes
    self.chattime.minutes
  end

  def save_with_parsecom!
    if self.parsecomhash
      parse_workload = ParsecomWorkload.find(self.parsecomhash)
    else
      parse_workload = ParsecomWorkload.new(user: ParsecomUser.find(User.find(self.user_id).parsecomhash))
    end
    if music_id
      key_val = self.music.key.split(':')
      key = key_val.first
      val = key_val.last
      val = val.to_i if ['sc', 'et'].include?(key)
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
      self.parsecomhash = parse_workload.id
      save!
    else
      raise parse_workload.inspect
    end
  end

  def chatting?
    created_at + Workload.pomominutes < Time.now && Time.now < created_at + Workload.pomominutes + Workload.chatminutes
  end

  def icon
    #user.present? ? user.icon : "https://ruffnote.com/attachments/24311"
    begin
      user.icon
    rescue
      u= User.find(self.user_id)
      u.present? ? u.icon : "https://ruffnote.com/attachments/24311"
    end
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
      created_at: (Time.now - Workload.pomominutes)..Time.now
    ).where(
      status: 0
    ).order('created_at desc')
  end

  def self.chattings
    # 現在時間から24分前が今からchat開始した人のcreatedAt
    last = Time.now - Workload.pomominutes
    # 上記時間のさらに5分前が今からchatが終わる人のcreatedAt
    start = last - Workload.chatminutes
    Workload.where(
      created_at: start..last
    ).where(
      status: 1
    ).order('created_at desc')
  end

  def self.dones limit = 48
    Workload.where(
      status: 1
    ).where(
      #"created_at < ?", Time.now - Workload.pomominutes - Workload.chatminutes 
      :created_at.lt => Time.now - Workload.pomominutes - Workload.chatminutes 
    ).order('created_at desc').limit(limit)
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
    ParsecomWorkload.sync
#    data = ParsecomWorkload.where(workload_id: nil).sort{|a, b| 
#      a.attributes['createdAt'].to_time <=> b.attributes['createdAt'].to_time
#    }
#    if !is_all && !Workload.count.zero?
#      from = Workload.last.created_at.to_time
#      data.select!{|w| w.attributes['createdAt'].to_time > from}
#    end
#
#    data.each do |u|
#      attrs = u.attributes
#      instance = Workload.find_or_initialize_by(
#        parsecomhash: attrs['objectId']
#      )
#      instance.status  = attrs['is_done']
#      begin
#        instance.user_id = User.find_by(
#          parsecomhash: attrs['user']['objectId']
#        ).id
#      rescue
#        # 初期のWorkloadはuserカラムがなくTwitterカラムだった
#      end
#      instance.created_at = attrs['createdAt'].to_time
#      instance.save!
#      u.workload_id = instance.id
#      u.save
#    end
  end
end

