class Music < ActiveRecord::Base
  has_many :workloads
  attr_accessor :total

  def self.sc_client_id
    '2b9312964a1619d99082a76ad2d6d8c6'
  end

  def fetch
    uri = self.class.json_url

    uri = URI.parse(uri)
    json = Net::HTTP.get(uri)
    result = JSON.parse(json)

    #raise result.inspect
    self.title = result['title']
    self.icon = result['artwork_url']
    self.save!
  end

  def self.json_url
    if key.match(/^sc:/)
      "https://api.soundcloud.com/tracks/#{key2}.json?client_id=#{self.class.sc_client_id}"
    elsif self.match(/^mc:/)
      "http://api.mixcloud.com#{key2}"
    elsif self.match(/^yt:/)
    elsif self.match(/^et:/)
    elsif self.match(/^sm:/)

    end
  end

  def key2
    key.gsub(/^..:/, '')
  end

  def users
    MusicsUser.limit(100).order(
      'total desc'
    ).where(
      music_id: self.id
    ).map{|mu| user = mu.user; user.total = mu.total; user}
  end

  def icon2
    icon ? icon : 'https://ruffnote.com/attachments/24162'
  end

  def key_old
    return nil unless key
    key.gsub(
      /^sc:/, 'soundcloud:'
    ).gsub(
      /^mc:/, 'mixcloud:'
    ).gsub(
      /^yt:/, 'youtube:'
    ).gsub(
      /^et:/, '8tracks:'
    ).gsub(
      /^sm:/, 'nicovideo:'
    ).gsub(
      /.0$/, ''
    )
  end
end

