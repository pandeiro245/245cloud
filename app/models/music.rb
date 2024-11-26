class Music < ApplicationRecord
  def self.fetch_soundcloud_from_workloads
    Workload.where.not(music_key: nil).map { |m| m.music_key }.uniq.grep(/soundcloud:/).each do |music_key|
      key = music_key.split(':').last
      music = Music.find_or_initialize_by(
        provider: 'soundcloud',
        key: key
      )
      workload = Workload.find_by(music_key: music_key)
      music.title = workload.title
      music.artwork_url = workload.artwork_url
      music.save!
    end
  end

  def self.new_from_key(provider, key)
    Music.find_or_initialize_by(provider: provider, key: key)
  end

  def self.search(word)
    api_key = ENV.fetch('YOUTUBE_TOKEN', nil)
    params = {
      q: word,
      key: api_key,
      part: 'id,snippet',
      videoDuration: 'long',
      type: 'video',
      maxResults: 30
    }
    url = URI("https://www.googleapis.com/youtube/v3/search?#{URI.encode_www_form(params)}")
    response = Net::HTTP.get(url)
    JSON.parse(response)['items'].map do |item|
      music = Music.find_or_initialize_by(
        provider: 'youtube',
        key: item['id']['videoId']
      )
      music.artwork_url = item['snippet']['thumbnails']['default']['url']
      music.title = item['snippet']['title']
      music.save!
      music
    end
  end

  # def initialize key
  #   workload = Workload.find_by(
  #     music_key: key
  #   )
  #   workload = Workload.find_by(
  #     music_key: URI.decode_www_form_component(key)
  #   ) unless workload
  #   if workload
  #     @title = workload.title
  #     @artwork_url = workload.artwork_url
  #   else
  #     fetch
  #   end
  # end

  def users
    Workload.best_listeners(provider_and_key) 
  end

  def provider_and_key
    "#{provider}:#{key}"
  end

  def url
    raise unless provider == 'youtube'
    "https://www.youtube.com/watch?v=#{key}"
  end

  def fetch
    return fetch_youtube if provider == 'youtube'
    workload_music_key = URI.decode_www_form_component("#{provider}:/#{key}")
    workload = Workload.find_by(music_key: workload_music_key)
    self.title = workload.title
    self.artwork_url = workload.artwork_url
    save!
  end

  def fetch_youtube
    api_key = ENV.fetch('YOUTUBE_TOKEN', nil)
    url = URI("https://www.googleapis.com/youtube/v3/videos?id=#{key}&key=#{api_key}&part=snippet,contentDetails")
    response = Net::HTTP.get(url)
    result = JSON.parse(response)

    self.title = result['items'].first['snippet']['title']
    self.artwork_url = result['items'].first['snippet']['thumbnails']['medium']['url']
    str = result['items'].first['contentDetails']['duration']
    match = /PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/.match(str)
    hours = (match[1] || 0).to_i
    minutes = (match[2] || 0).to_i
    seconds = (match[3] || 0).to_i
    self.duration = (hours * 3600) + (minutes * 60) + seconds
    save!
  end

  def active?
    uri = URI.parse(url)
    res = Net::HTTP.get_response(uri)
    body = res.body
    code = res.code
    return false if code == '404'
    if code == '200' && url.match(/www.mixcloud.com/)
      return false if body.match(/<h1 class="error-header">Show Deleted<\/h1>/)
    end
    return true # FIXME
  end

  def self.repairs!
    Workload.all.each do |w|
      w.repair!
    end
  end
end
