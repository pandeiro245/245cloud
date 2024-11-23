# config/puma.rb

require 'puma/minissl'
require 'dotenv'
Dotenv.load

# 基本設定
environment ENV.fetch("RAILS_ENV", "production")
app_dir = ENV.fetch("APP_DIR", Dir.pwd)
directory app_dir

# スレッド設定
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3).to_i
threads threads_count, threads_count

# 環境変数の表示
puts "=== Environment Variables ==="
puts "RAILS_ENV: #{ENV.fetch('RAILS_ENV', nil)}"
puts "PORT: #{ENV.fetch('PORT', nil)}"
puts "HTTP_PORT: #{ENV.fetch('HTTP_PORT', nil)}"
puts "HTTPS_PORT: #{ENV.fetch('HTTPS_PORT', nil)}"
puts "APP_DIR: #{ENV.fetch('APP_DIR', nil)}"
puts "DOMAIN: #{ENV.fetch('DOMAIN', nil)}"
puts "USE_SSL: #{ENV.fetch('USE_SSL', nil)}"
puts "=========================="

# HTTPポートの設定
port ENV.fetch('HTTP_PORT', '80')

# HTTPSポートの設定
puts "Checking SSL configuration..."
if ENV['USE_SSL'] == 'true'
  ssl_key_path = ENV.fetch('SSL_KEY_PATH')
  ssl_cert_path = ENV.fetch('SSL_CERT_PATH')

  puts "Configuring SSL..."
  puts "Key path: #{ssl_key_path}"
  puts "Cert path: #{ssl_cert_path}"

  ssl_bind '0.0.0.0',
           ENV.fetch('HTTPS_PORT', '443'),
           {
             key: ssl_key_path,
             cert: ssl_cert_path,
             verify_mode: 'none',
             no_tlsv1: true,
             no_tlsv1_1: true
           }
  puts "SSL configuration complete"
else
  puts "SSL is not enabled"
end

# プロセス管理
pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"

# ワーカー設定
workers ENV.fetch("WEB_CONCURRENCY", 2).to_i
preload_app!

# データベース接続管理
before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# エラーハンドリング
lowlevel_error_handler do |e|
  puts "Low-level error: #{e.message}"
  puts e.backtrace.join("\n")
  [500, {}, ["An error has occurred. Please try again later.\n"]]
end
