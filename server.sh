#!/bin/bash

# 環境変数の設定
export RAILS_ENV=production

# アプリケーションの更新
git pull origin develop

# 依存関係の更新
bundle install

# アセットのプリコンパイル
bin/rails assets:precompile

# Pumaの再起動
if [ -f tmp/pids/puma.pid ]; then
  echo "Gracefully restarting Puma..."
  pumactl -P tmp/pids/puma.pid phased-restart
else
  echo "Starting Puma..."
  bundle exec puma -C config/puma.rb -d
fi

# 状態確認
sleep 5
if [ -f tmp/pids/puma.pid ]; then
  echo "Puma is running with PID: $(cat tmp/pids/puma.pid)"
else
  echo "Failed to start Puma"
  exit 1
fi
