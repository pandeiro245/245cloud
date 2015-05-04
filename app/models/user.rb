class User < ActiveRecord::Base
  has_many :workloads
  attr_accessor :total

  def icon
    "https://ruffnote.com/attachments/24311"
  end

  def facebook_id
    email.split('@').first
  end

  def musics
    MusicsUser.limit(100).order(
      'total desc'
    ).where(
      user_id: self.id
    ).map{|mu| music = mu.music; music.total = mu.total; music}
  end
end

