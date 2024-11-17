require 'puma/minissl'
require 'dotenv'

Dotenv.load

# config/puma.rb の先頭に追加
puts "Environment: #{ENV.fetch('RAILS_ENV', nil)}"
puts "Port: #{ENV.fetch('PORT', nil)}"
puts "USE_SSL: #{ENV.fetch('USE_SSL', nil)}"
puts "SSL Key Path: #{ENV.fetch('SSL_KEY_PATH', nil)}"
puts "SSL Cert Path: #{ENV.fetch('SSL_CERT_PATH', nil)}"

environment ENV.fetch("RAILS_ENV") { "development" }

threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

if ENV['USE_SSL'] == 'true'
  ssl_bind '0.0.0.0', '8443', {
    key: ENV.fetch('SSL_KEY_PATH'),
    cert: ENV.fetch('SSL_CERT_PATH'),
    verify_mode: 'none',
    no_tlsv1: true,
    no_tlsv1_1: true
  }
else
  port ENV.fetch('PORT', '8080')
end

# directory '/home/ec2-user/stable'

plugin :tmp_restart
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]
