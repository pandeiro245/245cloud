class Tweet
  def initialize keys_json
    keys = JSON.parse(keys_json)
    @client = ::Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_KEY']
      config.consumer_secret = ENV['TWITTER_SECRET']
      config.access_token    = keys['twitter_token']
      config.access_token_secret = keys['twitter_secret']
    end
  end

  def notifications
    (@client.retweets_of_me +
    @client.mentions_timeline +
    @client.favorites).sort { |a, b| b['id'] <=> a['id'] }
  end

  def home
    @client.home_timeline(count: 100)
  end

  def yaruki
    name = 'motivation_up8'
    @client.user_timeline(name)
  end
end

