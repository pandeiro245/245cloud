#!/bin/bash

# エラー時に停止
set -e

if [ -f tmp/pids/puma.pid ]; then
  echo "Stopping Puma..."
  if ps -p $(cat tmp/pids/puma.pid) > /dev/null; then
    kill -TERM $(cat tmp/pids/puma.pid)
    # プロセスが終了するまで待機
    while ps -p $(cat tmp/pids/puma.pid) > /dev/null; do
      echo "Waiting for Puma to stop..."
      sleep 1
    done
  fi
  rm -f tmp/pids/puma.pid
  echo "Puma stopped"
else
  echo "Puma is not running (no pid file found)"
fi
