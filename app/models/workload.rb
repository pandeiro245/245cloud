# app/models/workload.rb
class Workload < ActiveRecord::Base
  include WorkloadMusicConcern

  POMOTIME = Rails.env.production? ? 24.minutes : 0.2.minutes
  CHATTIME = Rails.env.production? ? 5.minutes : 0.2.minutes

  belongs_to :user

  validate :music_key_presence_if_title_or_artwork_url_present
  before_save :set_music_key

  scope :created, -> { order('workloads.created_at DESC') }
  scope :dones, -> { where(is_done: true) }
  scope :his, ->(user_id) { where(user_id: user_id, is_done: true) }

  scope :chattings, -> {
    now = Time.zone.now
    where(created_at: (now - POMOTIME - CHATTIME)..(now - POMOTIME))
  }

  scope :playings, -> {
    now = Time.zone.now
    where(created_at: (now - POMOTIME)..now)
  }

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

    def recalculate_numbers_for_user(user_id, start_date:, end_date:)
      start_time = Time.zone.parse(start_date).beginning_of_day
      end_time = Time.zone.parse(end_date).end_of_day

      where(user_id: user_id)
        .where(created_at: start_time..end_time)
        .where(is_done: true)
        .order(:created_at)
        .each do |workload|
          tokyo_time = workload.created_at.in_time_zone('Tokyo')
          day_start = tokyo_time.beginning_of_day
          week_start = tokyo_time.beginning_of_week

          daily_count = where(user_id: user_id)
                        .where(is_done: true)
                        .where('created_at >= ? AND created_at <= ?', day_start, workload.created_at)
                        .count

          weekly_count = where(user_id: user_id)
                         .where(is_done: true)
                         .where('created_at >= ? AND created_at <= ?', week_start, workload.created_at)
                         .count

          workload.update!(number: daily_count, weekly_number: weekly_count)
        end
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
    self.class.recalculate_numbers_for_user(
      user_id,
      start_date: created_at.in_time_zone('Tokyo').to_date.to_s,
      end_date: created_at.in_time_zone('Tokyo').to_date.to_s
    )
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
