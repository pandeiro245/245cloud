Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  provider :timecrowd, ENV['TIMECROWD_KEY'], ENV['TIMECROWD_SECRET']
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end
OmniAuth.config.logger = Rails.logger
