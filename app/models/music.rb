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

    @title = workload.title
    @artwork_url = workload.artwork_url
  end

  def users
    Workload.best_listeners(key) 
  end
end
