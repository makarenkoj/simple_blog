#!/bin/bash
# Interpreter identifier

# Exit on fail
set -e

rm -f $APP_HOME/tmp/pids/server.pid

#bundle exec rake db:create
bundle exec rake db:migrate

exec "$@"
