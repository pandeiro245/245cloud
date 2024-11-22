# Pumaの基本設定
environment ENV.fetch("RAILS_ENV") { "development" }
port ENV.fetch("PORT") { 8080 }

# アプリケーションのディレクトリ設定
directory File.expand_path("../..", __FILE__)

# プロセス管理
pidfile "tmp/pids/puma.pid"
state_path "tmp/pids/puma.state"

# スレッド設定
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 3 }
threads threads_count, threads_count

# 本番環境の場合のみワーカーを設定
if ENV.fetch("RAILS_ENV") == "production"
  workers ENV.fetch("WEB_CONCURRENCY") { 2 }
  preload_app!

  # データベース接続の管理
  before_fork do
    ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
  end

  on_worker_boot do
    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
end

# ログ設定
if ENV.fetch("RAILS_ENV") == "production"
  stdout_redirect "log/puma.stdout.log", "log/puma.stderr.log", true
end

# エラーハンドリング
lowlevel_error_handler do |e|
  [500, {}, ["An error has occurred, please check the server logs.\n"]]
end

# プラグイン
plugin :tmp_restart
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]
