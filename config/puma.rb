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
puts "RAILS_ENV: #{ENV.fetch('RAILS_ENV', 'not set')}"
puts "PORT: #{ENV.fetch('PORT', 'not set')}"
puts "HTTP_PORT: #{ENV.fetch('HTTP_PORT', 'not set')}"
puts "HTTPS_PORT: #{ENV.fetch('HTTPS_PORT', 'not set')}"
puts "APP_DIR: #{ENV.fetch('APP_DIR', 'not set')}"
puts "DOMAIN: #{ENV.fetch('DOMAIN', 'not set')}"
puts "USE_SSL: #{ENV.fetch('USE_SSL', 'not set')}"
puts "=========================="

# HTTPポートの設定（SSLが無効の場合のみ）
unless ENV['USE_SSL'] == 'true'
  port ENV.fetch('HTTP_PORT', '80')
end

# HTTPSポートの設定
puts "Checking SSL configuration..."
if ENV['USE_SSL'] == 'true'
  begin
    ssl_key_path = ENV.fetch('SSL_KEY_PATH')
    ssl_cert_path = ENV.fetch('SSL_CERT_PATH')
    
    puts "Configuring SSL..."
    puts "Key path: #{ssl_key_path}"
    puts "Cert path: #{ssl_cert_path}"
    
    if File.exist?(ssl_key_path) && File.exist?(ssl_cert_path)
      ssl_bind '0.0.0.0',
               ENV.fetch('HTTPS_PORT', '443'),
               {
                 key: ssl_key_path,
                 cert: ssl_cert_path,
                 verify_mode: 'none',
                 no_tlsv1: true,
                 no_tlsv1_1: true,
                 ssl_version: 'TLSv1_2'
               }
      puts "SSL configuration complete"
    else
      puts "ERROR: SSL certificate files not found"
      puts "Key file exists: #{File.exist?(ssl_key_path)}"
      puts "Cert file exists: #{File.exist?(ssl_cert_path)}"
      exit 1
    end
  rescue KeyError => e
    puts "ERROR: Missing required SSL environment variables"
    puts e.message
    exit 1
  rescue => e
    puts "ERROR: Failed to configure SSL"
    puts e.message
    puts e.backtrace
    exit 1
  end
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
  puts "Low-level error: #
