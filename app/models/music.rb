class Music < ActiveRecord::Base
  has_many :workloads
  attr_accessor :total

  def self.sc_client_id
    '2b9312964a1619d99082a76ad2d6d8c6'
  end

  def fetch
    uri = json_url

    uri = URI.parse(uri)

    res = Net::HTTP.get(uri)

    if key.match(/^mc:/).present?
      result = JSON.parse(res)
      title = result['name']
      icon = result['pictures']['medium']
    elsif key.match(/^sm:/).present?
      req = Net::HTTP::Get.new(uri)
      xml = Net::HTTP.start(uri.host, uri.port) {|http|
        http.request(req)
      }.body
      require 'active_support/core_ext/hash/conversions'
      hash = Hash.from_xml(xml)
      data = hash["nicovideo_thumb_response"]["thumb"]
      title = data['title']
      icon = data['thumbnail_url']
    else
      result = JSON.parse(res)
      title = result['title']
      icon = result['artwork_url']
    end
    self.title = title
    self.icon  = icon
    self.save!
  end

  def json_url
    if key.match(/^sc:/)
      "https://api.soundcloud.com/tracks/#{key2}.json?client_id=#{self.class.sc_client_id}"
    elsif key.match(/^mc:/)
      "http://api.mixcloud.com#{key2}"
    elsif key.match(/^yt:/)
    elsif key.match(/^et:/)
    elsif key.match(/^sm:/)
      "http://ext.nicovideo.jp/api/getthumbinfo/#{key2}"
    end
  end

  def key2
    URI.encode key.gsub(/^..:/, '')
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

