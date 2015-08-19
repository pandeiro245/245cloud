#class User < ActiveRecord::Base
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :parsecomhash, type: String
  field :name, type: String
  field :email, type: String

  has_many :workloads
  #has_many :comments, -> {order('created_at desc')}
  #attr_accessor :total
  
  def self.current_user user_id
    #User.find(user_id)
    begin
      User.find(user_id)
    rescue
      nil
    end
  end

  def workload
    workloads = Workload.where(
      created_at: (Time.now - Workload.pomotime.minutes - 6.minutes)..(Time.now)
    ).where(
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

  def nothing?
    !chatting? && !playing?
  end

  def chatting?
    chatting_workload.present?
  end

  def chatting_workload
    Workload.chattings.where(
      user_id: self.id
    ).first
  end

  def self.login data
    #auth = Auth.find_or_create_with_omniauth(data)
    #if auth.user.parsecomhash.nil?
    #  auth.user.parsecomhash = ParsecomUser.where(facebook_id_str: auth.user.facebook_id.to_s).first.id
    #  auth.user.save!
    #end
    #auth.user
    User.find_or_create_by(
      email: "#{Auth.uid(data)}@245cloud.com"
    )
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

  def self.sync limit = 1000
    data = ParsecomUser.limit(limit).sort{|a, b| 
      a.attributes['createdAt'].to_time <=> b.attributes['createdAt'].to_time
    }
    data.each do |u|
      attrs = u.attributes
      user = User.find_or_create_by(
        parsecomhash: attrs['objectId']
      )
      user.name  = attrs['name']
      user.email = "parse-#{attrs['objectId']}@245cloud.com"
      user.save!
      Auth.find_or_create_by(
        user: user,
        uid: attrs['facebook_id_str'],
        provider: "facebook"
      )
    end
  end
end

