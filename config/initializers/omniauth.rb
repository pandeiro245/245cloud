Rails.application.config.middleware.use OmniAuth::Builder do
  provider :timecrowd, ENV['TIMECROWD_KEY'], ENV['TIMECROWD_SECRET']
end
OmniAuth.config.logger = Rails.logger
