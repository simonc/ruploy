# Outputs [OK] or [KO] given the previous status code 0=ok *=ko
ok_ko() {
  local status=$?

  case $status in
    0)
      echo "[OK]"
      ;;
    *)
      echo "[KO]"
      ;;
  esac

  return $status
}

# returns the name of the running server process
server_process() {
  case $SERVER in
    passenger) echo "nginx";;
    thin)      echo "thin";;
    *)         echo "unknown_server";;
  esac
}

# Returns the PID of the given server instance
server_pid() {
  if [ -e "$PIDFILE" ]; then
    if pidof $(server_process) | tr ' ' '\n' | grep -w $(cat $PIDFILE); then
      return 0
    fi
  fi
  return 1
}

# Returns the log-file option for the given server type
logfile_option() {
  case $SERVER in
    passenger) echo "--log-file";;
    thin)      echo "--log";;
    *)         echo "unknown_server";;
  esac
}

# Returns the pid-file option for the given server type
pidfile_option() {
  case $SERVER in
    passenger) echo "--pid-file";;
    thin)      echo "--pid";;
    *)         echo "unknown_server";;
  esac
}

# Returns the directory opion for the given server type
directory_option() {
  case $SERVER in
    passenger) echo "";;
    thin)      echo "--chdir";;
    *)         echo "unknown_server";;
  esac
}

# Starts the given server instance
ruploy_start() {
  echo -n "Starting ${NAME}... "
  $SERVER start                     \
    $(directory_option) $DIRECTORY  \
    --address      $ADDRESS         \
    --port         $PORT            \
    --environment  $ENVIRONMENT     \
    --user         $USER            \
    $(pidfile_option) $PIDFILE      \
    $(logfile_option) $LOGFILE      \
    $OPTIONS > /dev/null
  ok_ko
}

# Stops the given server instance
ruploy_stop() {
  echo -n "Stopping ${NAME}... "
  $SERVER stop --pid-file $PIDFILE > /dev/null 2>&1
  ok_ko
}

# Gives the status of the given server
ruploy_status() {
  PID=$(server_pid) || true
  if [ -n "$PID" ]; then
    echo "${NAME} is running (pid $PID)."
    return 0
  else
    echo "${NAME} is NOT running."
    return 1
  fi 
}

# Loading the rvm environment of the application
. $DIRECTORY/.rvmrc

case "$1" in
  restart)
    ruploy_stop
    ruploy_start
    exit $?
    ;;
  start)
    ruploy_start
    exit $?
    ;;
  status)
    ruploy_status
    exit $?
    ;;
  stop)
    ruploy_stop
    exit $?
    ;;
  *)
    echo "Usage: $0 {restart|start|status|stop}"
    exit 1
    ;;
esac

exit 0
