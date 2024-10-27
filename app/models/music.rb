class Music
  attr_accessor :key, :title, :artwork_url, :duration
  def initialize key
    @key = key
    workload = Workload.find_by(
      music_key: key
    )
    workload = Workload.find_by(
      music_key: URI.decode_www_form_component(key)
    ) unless workload
    if workload
      @title = workload.title
      @artwork_url = workload.artwork_url
    else
      fetch
    end
  end

  def id
    return nil if key.blank?
    key.split(':').last
  end

  def provider
    return nil if key.blank?
    key.split(':').first
  end

  def users
    Workload.best_listeners(key) 
  end

  def url
    # TODO
  end

  def fetch
    api_key = ENV['YOUTUBE_TOKEN']
    id = key.split(':').last
    url = URI("https://www.googleapis.com/youtube/v3/videos?id=#{id}&key=#{api_key}&part=snippet,contentDetails")
    response = Net::HTTP.get(url)
    result = JSON.parse(response)

    @title = result['items'].first['snippet']['title']
    @artwork_url = result['items'].first['snippet']['thumbnails']['medium']['url']
    str = result["items"].first["contentDetails"]["duration"]
    match = /PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/.match(str)
    hours = (match[1] || 0).to_i
    minutes = (match[2] || 0).to_i
    seconds = (match[3] || 0).to_i
    @duration = hours * 3600 + minutes * 60  + seconds
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

