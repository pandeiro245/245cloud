class User < ActiveRecord::Base
  has_many :workloads
  attr_accessor :total

  def name
    "ユーザ名表示実装中"
  end

  def workload
    workloads = Workload.where(
      created_at: (Time.now - Workload.pomotime.minutes - 6.minutes)..(Time.now)
    ).where(
      status: 0,
      user: self
    )
    workloads.present? ? workloads.first : nil
  end

  def workloads
    Workload.where(
      status: 1,
      user: self
    ).order('created_at desc').limit(24)
  end

  def playing?
    Workload.playings.where(
      user_id: self.id
    ).present?
  end

  def chatting_workload
    Workload.chattings.where(
      user_id: self.id
    ).first
  end

  def self.login data
    auth = Auth.find_or_create_with_omniauth(data)
    auth.user
  end

  def icon
    #"https://ruffnote.com/attachments/24311"
    "https://graph.facebook.com/#{facebook_id}/picture?type=square"
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
