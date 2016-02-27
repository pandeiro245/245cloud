class Music
  attr_accessor :key, :title, :artwork_url
  def initialize key
    @key = key
    workload = Workload.find_by(
      music_key: key
    )
    workload = Workload.find_by(
      music_key: URI.decode(key)
    ) unless workload
    if workload
      @title = workload.title
      @artwork_url = workload.artwork_url
    end
  end

  def users
    Workload.best_listeners(key) 
  end

  def url
    # TODO
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

