class Workload < ActiveRecord::Base
  # POMOTIME = 24.minutes
  # CHATTIME = 5.minutes
  POMOTIME = (0.1).minutes
  CHATTIME = (0.1).minutes

  validate :music_key_presence_if_title_or_artwork_url_present 

  belongs_to :user

  before_save :set_music_key

  scope :created, -> {
    order('workloads.created_at DESC')
  }
  scope :dones, -> {
    where(is_done: true)
  }
  scope :his, -> (user_id) {
    where(
      user_id: user_id
    )
  }
  scope :bests, -> {
    select(
      'music_key, COUNT(music_key) AS music_key_count'
    ).where.not(music_key: '')
     .group(:music_key)
     .order('music_key_count DESC')
  }
  scope :best_listeners, -> (music_key) {
    select(
      'user_id, COUNT(user_id) AS user_id_count'
    ).where(music_key: music_key)
     .group(:user_id)
     .order('user_id_count DESC')
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

  def hm
    time = created_at.in_time_zone('Tokyo')
    if time.to_date == Time.zone.now.to_date
      time.strftime('%H:%M')
    else
      time.strftime('%m/%d %H:%M')
    end
  end

  def will_reload_at
    case user.status
    when 'playing'
      created_at + POMOTIME
    when 'chatting'
      created_at + POMOTIME + CHATTIME
    else
      nil
    end
  end

  def remain
    (created_at + POMOTIME).to_i - Time.zone.now.to_i
  end

  def self.find_or_start_by_user(user, _params = {})
    w = playings.his(user.id).first
    return w if w.present?

    params = {'user_id' => user.id}
    %w(music_key title artwork_url).each do |key|
      if _params[key].present?
        params[key] = _params[key]
      end
    end
    self.create!(params)
  end

  def set_music_key
    return nil if self.music_key.nil?
    self.music_key = URI.decode_www_form_component(self.music_key)
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
    scope = Workload.his(user_id).dones
    scope = case type
    when :weekly
      scope.thisweek(created_at)
    else
      scope.today(created_at)
    end
    scope.count + 1
  end

	def music
		@music ||= Music.new_from_key(music_key.split(':').first, music_key.split(':').last)
	end

  def music_path
    key = music_key.gsub(/:/, '/')
    "/musics/#{key}"
  end

  def repair!
    return unless music_key
    if music_key.match(/^mixcloud:/)
      puts music_key
      self.music_key = URI.decode_www_form_component(self.music_key)
      self.save!
    end
  end

  def artwork_url_from_music
    return nil if music.blank?
    @artwork_url_from_music ||= music.artwork_url
  end

  def youtube_start
    music.fetch if music.provider == 'youtube' && music.duration.blank?
    music.duration - remain
  end

  def self.for1027
    Workload.where(music_key: nil).where.not(artwork_url: nil).each do |w|
      w.music_key = Workload.where.not(music_key: nil).where(artwork_url: w.artwork_url).limit(1).first.music_key
      w.save!
    end
  end

  private

  def music_key_presence_if_title_or_artwork_url_present
    if (title.present? || artwork_url.present?) && music_key.blank?
      errors.add(:music_key, ' is required if either title or artwork_url is present')
    end
  end
end

