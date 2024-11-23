#!/bin/bash

# エラー時に停止
set -e

echo "Checking Puma status..."
if [ -f tmp/pids/puma.pid ] && ps -p $(cat tmp/pids/puma.pid) > /dev/null; then
  echo "Restarting Puma..."
  bundle exec pumactl -P tmp/pids/puma.pid restart
  
  # 再起動の確認
  sleep 2
  if ps -p $(cat tmp/pids/puma.pid) > /dev/null; then
    echo "Puma successfully restarted with PID: $(cat tmp/pids/puma.pid)"
  else
    echo "Failed to restart Puma"
    exit 1
  fi
else
  echo "Puma is not running. Starting fresh..."
  ./server.sh
fi
