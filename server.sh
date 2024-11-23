#!/bin/bash

# エラー時に停止
set -e

# .envファイルが存在する場合、環境変数として読み込む
if [ -f .env ]; then
  echo "Loading .env file..."
  export $(cat .env | grep -v ^# | xargs)
  
  # 環境変数の確認
  echo "=== Environment Variables ==="
  echo "RAILS_ENV: $RAILS_ENV"
  echo "PORT: $PORT"
  echo "HTTP_PORT: $HTTP_PORT"
  echo "HTTPS_PORT: $HTTPS_PORT"
  echo "DOMAIN: $DOMAIN"
  echo "APP_DIR: $APP_DIR"
  echo "USE_SSL: $USE_SSL"
  echo "SSL_KEY_PATH: $SSL_KEY_PATH"
  echo "SSL_CERT_PATH: $SSL_CERT_PATH"
  echo "=========================="
fi

# gitの更新
git pull origin develop

# 依存関係の更新
bundle install

# アセットのプリコンパイル
RAILS_ENV=production bundle exec rails assets:precompile

# ログディレクトリの作成（存在しない場合）
mkdir -p log
touch log/puma.stdout.log log/puma.stderr.log
chmod 0664 log/puma.stdout.log log/puma.stderr.log

# Pumaの起動または再起動
if [ -f tmp/pids/puma.pid ] && ps -p $(cat tmp/pids/puma.pid) > /dev/null; then
  echo "Restarting Puma..."
  bundle exec pumactl -P tmp/pids/puma.pid restart
else
  echo "Starting Puma..."
  nohup bundle exec puma -C config/puma.rb \
    >> log/puma.stdout.log \
    2>> log/puma.stderr.log &

  # PIDの保存
  echo $! > tmp/pids/puma.pid
fi

# 起動確認
sleep 2
if [ -f tmp/pids/puma.pid ] && ps -p $(cat tmp/pids/puma.pid) > /dev/null; then
  echo "Puma is running with PID: $(cat tmp/pids/puma.pid)"
  echo "Logs are available at:"
  echo "  - log/puma.stdout.log"
  echo "  - log/puma.stderr.log"
else
  echo "Failed to start Puma"
  exit 1
fi
