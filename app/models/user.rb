class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.add(name)
    u = User.create!(
      name: name,
      email: "#{name}@245cloud.com"
    )
    u.refresh_token!
    u
  end

  def self.sync_names
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_KEY']
      config.consumer_secret     = ENV['TWITTER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_KEY']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end

    self.where.not(twitter_id: nil).order('id desc').each do |user|
      begin
        twitter_user = client.user(user.twitter_id.to_i)
        user.screen_name = twitter_user.screen_name
        user.name = twitter_user.name
        user.save!
      rescue => e
        puts e.inspect
      end
    end
  end

  def url
    refresh_token! if token.blank?
    "https://245cloud.com/login?user_id=#{id}&token=#{token}"
  end

  def refresh_token!
    self.token = SecureRandom.hex(64)
    self.save!
  end

  def workloads
    Workload.his(id).bests.limit(48)
  end

  def start!(params={})
    Workload.find_or_start_by_user(self, params)
  end

  def to_done!
    w = Workload.his(
      id
    ).chattings.first
    w.to_done! if w.present?
    w
  end

  def email_required?
    false
  end

  def password_required?
    false
  end
end

