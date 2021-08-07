Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_SECRET']
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET'], {
    secure_image_url: 'true',
    image_size: 'bigger'
  }
end
OmniAuth.config.logger = Rails.logger
