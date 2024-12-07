module WorkloadMusicConcern
  extend ActiveSupport::Concern

  included do
    scope :bests, lambda {
      select('music_key, COUNT(music_key) AS music_key_count')
        .where.not(music_key: '')
        .group(:music_key)
        .order('music_key_count DESC')
    }

    scope :best_listeners, lambda { |music_key|
      select('user_id, COUNT(user_id) AS user_id_count')
        .where(music_key: music_key)
        .group(:user_id)
        .order('user_id_count DESC')
    }
  end

  def music
    @music ||= Music.new_from_key(*music_key.split(':'))
  end

  def music_path
    "/musics/#{formatted_music_key}"
  end

  def artwork_url_from_music
    music&.artwork_url
  end

  def youtube_start
    return unless music.provider == 'youtube'

    music.fetch if music.duration.blank?
    music.duration - remain
  end

  private

  def formatted_music_key
    music_key.gsub('mixcloud:/', 'mixcloud:').gsub(':', '/')
  end

  def music_key_presence_if_title_or_artwork_url_present
    return unless title.present? || artwork_url.present?

    errors.add(:music_key, 'is required if either title or artwork_url is present') if music_key.blank?
  end
end
