class Tweet
  def self.client keys_json
    keys = JSON.parse(keys_json)
    token = keys['twitter_token']
    secret = keys['twitter_secret']
    ::Twitter::REST::Client.new do |config|
      config.consumer_key    = ENV['TWITTER_KEY']
      config.consumer_secret = ENV['TWITTER_SECRET']
      config.access_token    = token 
      config.access_token_secret = secret
    end
    #@client.search("kintone", result_type: "recent", lang: "ja")
  end

  def self.notifications keys_json
    self.client(keys_json).retweets_of_me
  end

  def self.home keys_json
    self.client(keys_json).home_timeline(count: 100)
  end

  def self.yaruki keys_json
    name = 'motivation_up8'
    self.client(keys_json).user_timeline(name)
  end
end

