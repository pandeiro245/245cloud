# config/puma.rb
require 'puma/minissl'

# 環境設定
environment ENV.fetch("RAILS_ENV") { "production" }

# スレッド設定
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# SSL設定
ssl_bind '0.0.0.0', '8080', {
  key: "/home/ec2-user/stable/config/certs/privkey.pem.copy",
  cert: "/home/ec2-user/stable/config/certs/fullchain.pem.copy",
  verify_mode: 'none',
  no_tlsv1: true,
  no_tlsv1_1: true
}

# アプリケーションのディレクトリ
directory '/home/ec2-user/stable'

# プラグイン
plugin :tmp_restart
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]
