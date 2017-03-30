#! /bin/sh
### BEGIN INIT INFO
# Provides:          puma
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Example initscript
# Description:       This file should be used to construct scripts to be
#                    placed in /etc/init.d.
### END INIT INFO

# Do NOT "set -e"

PATH=/usr/local/bin:/usr/local/sbin/:/sbin:/usr/sbin:/bin:/usr/bin
DESC='Puma rack web server'

# ... main names...
APP_NAME="$(echo "$(basename "$0")" | sed 's/^puma_//')"
EXPECTED_APP_NAME='your_website'
APP_ROOT="/var/www/rails/$APP_NAME/current"

PUMA_CONFIG="$APP_ROOT/config/puma.rb"

export RAILS_ENV="${RAILS_ENV-production}"

NAME="$APP_NAME"
SCRIPTNAME="$0"

# ... dirs...
PUMA_DIR="$APP_ROOT/tmp/puma"
PID_DIR="$PUMA_DIR/pids"
PID_FILE="$PID_DIR/puma.pid"
STATE_FILE="$PID_DIR/puma.state"
SOCKETS_DIR="$PUMA_DIR/sockets"

LOG_DIR="$PUMA_DIR/log"
LOG_FILE="$LOG_DIR/puma.log"

AS_USER="${USER-rbdev}"

# ... Ruby env...
export RBENV_ROOT='/opt/ruby/rbenv/remote_server'
export RBENV_GEMSETS='rails'
export RBENV_VERSION='2.4.0'

PATH="$RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH"

# ... functions...
ERROR() {
  ( printf '%s\n'   "ERROR,  $0..."
    printf '\t%s\n' "$@" '' ) >&2
  kill $$
  # exit 1
}

create_dirs() {
  local dir=''
  for dir in "$@"; do
    [ -d "$dir" ] || mkdir -p "$dir" || ERROR
  done
}

fail_if_user_not_one_of() {
  local valid_user=''
  local current_user="$(id -un)"
  for valid_user in "$@"; do
    [ "$current_user" = "$valid_user" ] && return 0
  done

  ERROR "Current user '$current_user' is invalid." \
    "Valid users: '$(echo $@)'."
}

run () {
  local cmd="$1"
  local as_user="$2"
  if [ "$(id -un)" = "$as_user" ]; then
    eval "$cmd"
  else
    local env_var_list="PATH=$PATH"
    local env_var=''
    local val=''
    for env_var in RBENV_ROOT RBENV_VERSION RBENV_GEMSETS; do
      export | /bin/grep -q "export[ ][ ]*$env_var" || ERROR "Env var '$env_var' not set."
      eval val=\"\$$env_var\"
      env_var_list="$env_var_list; export $env_var='$val'"
    done

    su --command "$env_var_list; $cmd" --login "$as_user"
  fi
}

puma_is_running() {
  _puma_info "$@" >/dev/null
}

pid_from_file() {
  local pid_file="$1"
  local file_size="$(wc --bytes "$pid_file" | cut -f 1 -d ' ')"

  puma_is_running "$pid_file" ||
    ERROR 'Puma should be running if you are calling this function.'

  _puma_info "$pid_file"
}

_puma_info() {
  local pid_file="$1"
  [ -e "$pid_file" ] || return 1

  local pid_file_contents="$(get_file_contents "$pid_file")"

  printf '%s\n' "$pid_file_contents" | /bin/grep -q '^[0-9][0-9]*$' ||
    ERROR "invalid PID '$pid_file_contents' found in '$pid_file'."

  if [ "$(/bin/ps -A -o pid= | /bin/grep -c "$pid_file_contents")" -eq 0 ]; then
    return 1
  fi

  printf '%s\n' "$pid_file_contents"
  return 0
}

get_file_contents() {
  local file="$1"
  [ -r "$file" ] || ERROR "File '$file' not readable."
  cat "$file"
}

do_start() {
  local app_root="$1"
  local as_user="$2"
  local puma_config="$3"
  local log_file="$4"
  local rails_env="$5"
  local app_name="$6"

  log_daemon_msg '...' '\n'
  log_daemon_msg 'Starting' "   Puma '$app_root'"'\n'
  log_daemon_msg 'User' "       '$as_user'"'\n'
  log_daemon_msg 'Log to' "     '$log_file'"'\n'
  log_daemon_msg 'Environment' "'$rails_env'"'\n'

  local run_puma_file="/tmp/run_puma_$app_name.bash"
  printf '%s\n' \
    '#!/bin/bash' \
    "cd '$app_root' && exec bundle exec puma --environment '$rails_env' --config '$puma_config' 2>&1 >> '$log_file'" \
    > "$run_puma_file"

  sync
  chmod 0755 "$run_puma_file"
  start-stop-daemon --verbose --start --chdir "$app_root" --chuid "$as_user" --background --exec "$run_puma_file"
}

do_restart() {
  local app_root="$1"
  local as_user="$2"
  local puma_config="$3"
  local log_file="$4"
  local rails_env="$5"
  local app_name="$6"

  local pid_file="$7"
  local state_file="$8"

  if puma_is_running "$pid_file"; then
    log_daemon_msg 'About to restart' "Puma '$app_root'"'\n'
    run "cd '$app_root' && bundle exec pumactl --state '$state_file' restart" "$as_user"
  else
    log_daemon_msg '\n''Restart' "Puma '$app_root' was not running, starting..."'\n'
    do_start "$app_root" "$as_user" "$puma_config" "$log_file" "$rails_env" "$app_name"
  fi

  return 0
}

do_stop() {
  local app_root="$1"
  local as_user="$2"
  local pid_file="$3"
  local state_file="$4"

  log_daemon_msg 'Stopping' "'$app_root'"'\n'
  if puma_is_running "$pid_file"; then
    local pid="$(pid_from_file "$pid_file")"
    log_daemon_msg 'About to kill' "PID '$pid'"'\n'
    run "cd '$app_root' && bundle exec pumactl --state '$state_file' stop" "$as_user"

    # Many daemons don't delete their pid_files when they exit.
    rm -f "$pid_file" "$state_file"
  else
    log_daemon_msg 'Not running' "Puma '$app_root'"'\n'
  fi

  return 0
}

do_status() {
  local app_root="$1"
  local as_user="$2"
  local pid_file="$3"
  local state_file="$4"

  if puma_is_running "$pid_file"; then
    local pid="$(pid_from_file "$pid_file")"
    log_daemon_msg 'About to get status' "Puma '$app_root'"'\n'
    run "cd '$app_root' && bundle exec pumactl --state '$state_file' stats" "$as_user"
  else
    log_daemon_msg 'Not running' "Puma '$app_root'"'\n'
  fi

  return 0
}

# ********************************* #
# --- **** start "MAIN"... **** --- #
# ********************************* #

rbenv rehash

[ "$APP_NAME" = "$EXPECTED_APP_NAME" ] || \
  ERROR "app name != expected, '$APP_NAME' != '$EXPECTED_APP_NAME'"

# Load the VERBOSE setting and other rcS variables
# ... must be before set -u because RUNLEVEL
. /lib/init/vars.sh || ERROR

set -u

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions || ERROR

create_dirs "$PID_DIR" "$SOCKETS_DIR" "$LOG_DIR"
fail_if_user_not_one_of "$AS_USER" 'root'

START_ARGS="$APP_ROOT $AS_USER $PUMA_CONFIG $LOG_FILE $RAILS_ENV $APP_NAME"
RESTART_ARGS="$START_ARGS $PID_FILE $STATE_FILE"
STOP_STATUS_ARGS="$APP_ROOT $AS_USER $PID_FILE $STATE_FILE"

case "$1" in
  start)
    [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"

    if puma_is_running "$PID_FILE"; then
      do_restart $RESTART_ARGS
      # do_restart "$APP_ROOT" "$AS_USER" "$PUMA_CONFIG" "$LOG_FILE" "$RAILS_ENV" "$APP_NAME" "$PID_FILE" "$STATE_FILE"
    else
      do_start $START_ARGS
      # do_start "$APP_ROOT" "$AS_USER" "$PUMA_CONFIG" "$LOG_FILE" "$RAILS_ENV" "$APP_NAME"
    fi

    case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
  ;;

  stop)
    [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"

    do_stop $STOP_STATUS_ARGS

    case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
  ;;

  status)
    log_daemon_msg "Status $DESC" "$NAME"'\n'

    do_status $STOP_STATUS_ARGS

    case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
  ;;

  restart)
    log_daemon_msg "Restarting $DESC" "$NAME"

    do_restart $RESTART_ARGS

    case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
  ;;

  *)
    echo "Usage:" >&2
    echo "  Run the jungle: $SCRIPTNAME {start|stop|status|restart}" >&2
    echo "  On a Puma: $SCRIPTNAME {start|stop|status|restart} PUMA-NAME" >&2
    exit 3
  ;;
esac
:
# ... edited by app gen (Puma)
