Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'] # TODO
  provider :discord, ENV['DISCORD_CLIENT_ID'], ENV['DISCORD_SECRET']
  provider :slack, ENV['SLACK_CLIENT_ID'], ENV['SLACK_SECRET'], scope: 'identity.basic'
end
OmniAuth.config.logger = Rails.logger
