#!/bin/bash

# エラー時に停止
set -e

# プロセスのクリーンアップ
if [ -f tmp/pids/puma.pid ]; then
  kill -TERM $(cat tmp/pids/puma.pid) 2>/dev/null || true
  rm -f tmp/pids/puma.pid
  sleep 2
fi

# アプリケーションの更新
git pull origin develop

# 依存関係の更新
bundle install

# アセットのプリコンパイル
RAILS_ENV=production bundle exec rails assets:precompile

# Pumaの起動
RAILS_ENV=production bundle exec puma -C config/puma.rb
