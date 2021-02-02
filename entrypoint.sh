#!/bin/bash

set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f $APP_HOME/tmp/pids/server.pid

bundle exec rake db:migrate

exec "$@"
