class Workload < ActiveRecord::Base
  POMOTIME = 24.minutes
  CHATTIME = 5.minutes
  # POMOTIME = (0.1).minutes
  # CHATTIME = (0.1).minutes

  before_save :set_music_key

  scope :created, -> {
    order('workloads.created_at DESC')
  }
  scope :dones, -> {
    where(is_done: true)
  }
  scope :his, -> (facebook_id) {
    where(
      facebook_id: facebook_id
    )
  }
  scope :bests, ->  { select(
    '*, count(music_key) as music_key_count'
  ).where.not(music_key: ''
  ).group(:music_key).order(
      'music_key_count DESC'
    )
  }
  scope :best_listeners, -> (music_key) { select(
    '*, count(facebook_id) as facebook_id_count'
  ).where(music_key: music_key
  ).group(:facebook_id).order(
      'facebook_id_count DESC'
    )
  }
  scope :today, -> (created_at = nil) {
    to = created_at || Time.zone.now
    to -= POMOTIME
    from = to.beginning_of_day
    where(
      created_at: from..to
    )
  }
  scope :thisweek, -> (created_at = nil) {
    to = created_at || Time.zone.now
    to -= POMOTIME
    from = to.to_date.beginning_of_day
    from = if created_at.wday == 0 # sunday
      from - 6.day
    else
      from - (created_at.wday - 1).day
    end
    where(
      created_at: from..to
    )
  }
  scope :chattings, -> {
    from = Time.zone.now - POMOTIME - CHATTIME
    to   = Time.zone.now - POMOTIME
    by_range(from..to)
  }
  scope :playings, -> {
    from = Time.zone.now - POMOTIME
    to   = Time.zone.now
    by_range(from..to)
  }
  scope :by_range, -> range {
    where(
      created_at: range
    )
  }
  scope :of_type, -> type {
    raise if type && !active_type?(type)
    type ? public_send(type) : dones
  }

  def self.find_or_start_by_user(user, _params = {})
    w = playings.his(user.facebook_id).first
    return w if w.present?

    params = {'facebook_id' => user.facebook_id}
    %w(music_key title artwork_url).each do |key|
      if _params[key].present?
        params[key] = _params[key]
      end
    end
    w = self.create!(params)
    w.number = w.next_number
    w.save!
    w
  end

  def set_music_key
    return nil if self.music_key.nil?
    self.music_key = URI.decode(self.music_key)
  end

  def playing?
    from = Time.zone.now - POMOTIME
    to   = Time.zone.now
    created_at > from && created_at < to
  end

  def remain_text
    remain = created_at + POMOTIME - Time.zone.now
    _min = (remain / 60).to_i
    _sec = remain - _min * 60
    format("%02d:%02d", _min, _sec)
  end

  def to_done!
    self.number = next_number
    self.weekly_number = next_number(:weekly)
    self.is_done = true
    self.save!
    self
  end

  def self.active_type? type
    %w(dones chattings playings all).include?(type)
  end

  def update_number!
    self.number = next_number
    self.weekly_number = next_number(:weekly)
    self.save!
  end

  def self.update_numbers
    self.created.dones.each do |w|
      w.update_number!
    end
  end

  def next_number type=nil
    scope = Workload.his(facebook_id).dones
    scope = case type
    when :weekly
      scope.thisweek(created_at)
    else
      scope.today(created_at)
    end
    scope.count + 1
  end

  def music_path
    key = music_key.gsub(/:/, '/')
    "/musics/#{key}"
  end

  def repair!
    return unless music_key
    if music_key.match(/^mixcloud:/)
      puts music_key
      self.music_key = URI.decode(self.music_key)
      self.save!
    end
  end
end

