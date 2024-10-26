# ps ax|grep unicorn|grep -v grep

MASTER_PID=$(ps ax | grep 'unicorn master' | grep -v grep | awk '{print $1}')

if [ -n "$MASTER_PID" ]; then
  echo "Killing unicorn master with PID: $MASTER_PID"
  kill -9 $MASTER_PID
else
  echo "unicorn master process not found."
fi



unicorn -c config/unicorn.conf -D
