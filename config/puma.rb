# config/puma.rb
require 'puma/minissl'
require 'dotenv'
Dotenv.load

# カスタム例外クラスの定義
class PumaConfigError < StandardError; end

# 基本設定
environment ENV.fetch("RAILS_ENV", "development")
app_dir = ENV.fetch("APP_DIR", Dir.pwd)
directory app_dir

# スレッド設定
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3).to_i
threads threads_count, threads_count

# 環境変数の表示
puts "=== Environment Variables ==="
puts "RAILS_ENV: #{ENV.fetch('RAILS_ENV', 'development')}"
puts "DOMAIN: #{ENV.fetch('DOMAIN', 'not set')}"
puts "APP_DIR: #{app_dir}"
puts "USE_SSL: #{ENV.fetch('USE_SSL', 'false')}"
puts "=========================="

# 環境に応じたポート設定
if ENV.fetch("RAILS_ENV", "development") == "production"
  puts "Running in production mode..."
  if ENV['USE_SSL'] == 'true'
    begin
      ssl_key_path = ENV.fetch('SSL_KEY_PATH')
      ssl_cert_path = ENV.fetch('SSL_CERT_PATH')
      
      puts "Configuring SSL..."
      puts "Key path: #{ssl_key_path}"
      puts "Cert path: #{ssl_cert_path}"
      
      if File.exist?(ssl_key_path) && File.exist?(ssl_cert_path)
        puts "SSL files exist and are readable"
        puts "Key file permissions: #{File.stat(ssl_key_path).mode.to_s(8)}"
        puts "Cert file permissions: #{File.stat(ssl_cert_path).mode.to_s(8)}"
        
        # 8080と8443ポートを使用
        bind "tcp://0.0.0.0:8080"
        bind "ssl://0.0.0.0:8443?key=#{ssl_key_path}&cert=#{ssl_cert_path}&verify_mode=none"
        
        puts "Port bindings complete (8080 and 8443)"
      else
        puts "ERROR: SSL certificate files not found"
        puts "Key file exists: #{File.exist?(ssl_key_path)}"
        puts "Cert file exists: #{File.exist?(ssl_cert_path)}"
        raise PumaConfigError, "SSL certificate files not found"
      end
    rescue KeyError => error
      puts "ERROR: Missing required SSL environment variables"
      puts error.message
      raise PumaConfigError, "Missing required SSL environment variables: #{error.message}"
    rescue StandardError => error
      puts "ERROR: Failed to configure SSL"
      puts error.message
      puts error.backtrace
      raise PumaConfigError, "Failed to configure SSL: #{error.message}"
    end
  else
    puts "SSL is not enabled in production"
    bind "tcp://0.0.0.0:8080"
  end
else
  puts "Running in development mode..."
  bind "tcp://0.0.0.0:8080"
end

# プロセス管理
pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"

# ワーカー設定
if ENV.fetch("RAILS_ENV", "development") == "production"
  workers ENV.fetch("WEB_CONCURRENCY", 2).to_i
  preload_app!
else
  workers ENV.fetch("WEB_CONCURRENCY", 0).to_i
end

# データベース接続管理
before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# エラーハンドリング
lowlevel_error_handler do |error|
  puts "Low-level error: #{error.message}"
  puts error.backtrace.join("\n")
  [500, {}, ["An error has occurred. Please try again later.\n"]]
end

# ログ設定
stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true if ENV.fetch("RAILS_ENV", "development") == "production"
