#!/bin/bash

# エラー時に停止
set -e

# 環境変数の設定
export RAILS_ENV=production
export PORT=8080
export RACK_ENV=production

# 関数: Pumaプロセスの状態確認
check_puma() {
  if [ -f tmp/pids/puma.pid ]; then
    if ps -p $(cat tmp/pids/puma.pid) > /dev/null 2>&1; then
      return 0  # プロセス実行中
    fi
  fi
  return 1  # プロセス未実行
}

# 関数: Pumaの安全な停止
stop_puma() {
  if [ -f tmp/pids/puma.pid ]; then
    echo "Stopping Puma..."
    kill -TERM $(cat tmp/pids/puma.pid) 2>/dev/null || true
    sleep 3
    # 強制終了が必要な場合
    if check_puma; then
      echo "Force stopping Puma..."
      kill -9 $(cat tmp/pids/puma.pid) 2>/dev/null || true
    fi
    rm -f tmp/pids/puma.pid
  fi
}

# メイン処理開始
echo "Starting deployment process..."

echo "Pulling latest changes..."
git pull origin develop

echo "Installing dependencies..."
bundle install

echo "Precompiling assets..."
bundle exec rails assets:precompile

# ディレクトリの作成
mkdir -p tmp/pids log

# ログファイルの準備
touch log/puma.stdout.log log/puma.stderr.log

# 既存のPumaプロセスの停止
stop_puma

echo "Starting Puma..."
bundle exec puma -C config/puma.rb --daemon

# 起動確認
for i in {1..10}; do
  if check_puma; then
    echo "Puma is running with PID: $(cat tmp/pids/puma.pid)"
    echo "Deployment completed successfully!"
    exit 0
  fi
  echo "Waiting for Puma to start... (Attempt $i/10)"
  sleep 2
done

echo "Failed to start Puma. Please check the logs:"
tail -n 20 log/puma.stdout.log log/puma.stderr.log
exit 1
