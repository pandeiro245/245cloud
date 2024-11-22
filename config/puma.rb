require 'puma/minissl'
require 'dotenv'
Dotenv.load

# 基本設定
environment ENV.fetch("RAILS_ENV") { "development" }
directory ENV.fetch("APP_DIR") { Dir.pwd }

# スレッド設定
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 3 }
threads threads_count, threads_count

# SSL設定
if ENV['USE_SSL'] == 'true'
  ssl_bind '0.0.0.0', ENV.fetch('PORT') { '8443' }, {
    key: ENV.fetch('SSL_KEY_PATH'),
    cert: ENV.fetch('SSL_CERT_PATH'),
    verify_mode: 'none',
    no_tlsv1: true,
    no_tlsv1_1: true
  }
else
  port ENV.fetch('PORT') { '8080' }
end

# プロセス管理
pidfile File.join(ENV.fetch("APP_DIR") { Dir.pwd }, "tmp/pids/puma.pid")
state_path File.join(ENV.fetch("APP_DIR") { Dir.pwd }, "tmp/pids/puma.state")

# ワーカープロセス設定
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
preload_app!

# 再起動時の設定
prune_bundler
plugin :tmp_restart

# Solid Queue設定
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end
