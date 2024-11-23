#!/bin/bash

# エラー時に停止
set -e

# 環境変数の設定
export RAILS_ENV=production

# アプリケーションの更新
git pull origin develop

# 依存関係の更新
bundle install

# アセットのプリコンパイル
bundle exec rails assets:precompile

# Pumaの起動または再起動
if [ -f tmp/pids/puma.pid ] && ps -p $(cat tmp/pids/puma.pid) > /dev/null; then
  echo "Performing phased restart..."
  bundle exec pumactl -P tmp/pids/puma.pid phased-restart
else
  echo "Starting Puma..."
  bundle exec puma -C config/puma.rb
fi
