require 'puma/minissl'
require 'dotenv'
Dotenv.load

# 環境設定
environment ENV.fetch("RAILS_ENV") { "development" }

# ディレクトリ設定
app_dir = File.expand_path("../..", __FILE__)
directory app_dir

# PIDファイルとステート設定
pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"

# ワーカープロセスの設定
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# スレッド数の設定
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 3 }
threads threads_count, threads_count

# プリロード設定
preload_app!

# ポートとSSLの設定
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

# フォーク後の接続設定
before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

after_fork do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# 管理CLI用のアクティベーション設定
activate_control_app

# プラグイン設定
plugin :tmp_restart
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# グレースフルリスタート設定
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

on_worker_shutdown do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end
