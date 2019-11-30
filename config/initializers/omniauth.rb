Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_SECRET']
end
OmniAuth.config.logger = Rails.logger
