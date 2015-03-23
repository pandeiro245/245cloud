class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :workloads

  def recent_musics
    Workload.limit(100).order(
      'id desc'
    ).where(
      user_id: self.id
    ).where(
      'music_id is not null'
    ).map{|w| w.music}.uniq!
  end
end

