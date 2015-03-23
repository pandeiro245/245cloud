class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :workloads
  attr_accessor :total

  def icon
    "https://graph.facebook.com/#{facebook_id}/picture?height=80&width=80"
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

