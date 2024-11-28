# app/models/workload.rb
class Workload < ActiveRecord::Base
  include WorkloadMusicConcern

  POMOTIME = Rails.env.production? ? 24.minutes : 0.2.minutes
  CHATTIME = Rails.env.production? ? 5.minutes : 0.2.minutes

  belongs_to :user

  # バリデーション
  validate :music_key_presence_if_title_or_artwork_url_present

  # コールバック
  before_save :set_music_key

  # 基本スコープ
  scope :created, -> { order('workloads.created_at DESC') }
  scope :dones, -> { where(is_done: true) }
  scope :his, ->(user_id) { where(user_id: user_id, is_done: true) }

  # 時間関連スコープ
  scope :by_range, ->(range) { where(created_at: range) }

  scope :today, ->(created_at = nil) {
    to = (created_at || Time.zone.now) - POMOTIME
    base_time = to.in_time_zone('Tokyo')
    from = base_time.beginning_of_day.in_time_zone('UTC')
    by_range(from..to)
  }

  scope :thisweek, ->(created_at = nil) {
    to = (created_at || Time.zone.now) - POMOTIME
    from = ::NumberCalculatorService.calculate_week_start(to)
    by_range(from..to)
  }

  scope :chattings, -> {
    now = Time.zone.now
    by_range((now - POMOTIME - CHATTIME)..(now - POMOTIME))
  }

  scope :playings, -> {
    now = Time.zone.now
    by_range((now - POMOTIME)..now)
  }

  # タイプ関連
  scope :of_type, ->(type) {
    raise ArgumentError, "Invalid type: #{type}" if type && !active_type?(type)
    type ? public_send(type) : dones
  }

  class << self
    def active_type?(type)
      %w[dones chattings playings all].include?(type)
    end

    def find_or_start_by_user(user, params = {})
      return playings.his(user.id).first if playings.his(user.id).exists?

      create!(build_create_params(user, params))
    end

    private

    def build_create_params(user, params)
      create_params = { 'user_id' => user.id }

      %w[title artwork_url].each do |key|
        create_params[key] = params[key] if params[key].present?
      end

      if params[:music_key].present?
        create_params[:music_key] = "#{params[:music_provider]}:#{params[:music_key]}"
      end

      create_params
    end
  end

  def will_reload_at
    case user.status
    when 'playing' then created_at + POMOTIME
    when 'chatting' then created_at + POMOTIME + CHATTIME
    end
  end

  def playing?
    Time.zone.now < (created_at + POMOTIME - 0.1.seconds)
  end

  def chatting?
    return false if playing?
    created_at + POMOTIME + CHATTIME > Time.zone.now
  end

  def remain
    (created_at + POMOTIME).to_i - Time.zone.now.to_i
  end

  def to_done!
    update!(is_done: true)
    recalculate_numbers
    self
  end

  def recalculate_numbers
    ::NumberCalculatorService.recalculate_numbers_for_user(user_id,
      start_date: created_at.in_time_zone('Tokyo').to_date,
      end_date: created_at.in_time_zone('Tokyo').to_date)
  end

  def hm
    time = created_at.in_time_zone('Tokyo')
    format = time.to_date == Time.zone.now.to_date ? '%H:%M' : '%m/%d %H:%M'
    time.strftime(format)
  end

  def disp
    return hm.to_s if created_at + POMOTIME + CHATTIME > Time.zone.now
    "#{hm} #{number}回目(週#{weekly_number}回)"
  end

  def finish_playing_time
    (created_at + POMOTIME).to_i * 1000
  end

  def finish_chatting_time
    (created_at + POMOTIME + CHATTIME).to_i * 1000
  end

  private

  def music_key_presence_if_title_or_artwork_url_present
    return unless title.present? || artwork_url.present?
    errors.add(:music_key, 'is required if either title or artwork_url is present') if music_key.blank?
  end

  def set_music_key
    self.music_key = URI.decode_www_form_component(music_key) if music_key.present?
  end
end
