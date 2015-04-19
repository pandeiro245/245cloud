class Music < ActiveRecord::Base
  has_many :workloads
  attr_accessor :total

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
      /.0$/, ''
    )
  end
end

