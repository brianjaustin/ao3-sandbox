#!/bin/bash -ex

for file in 'database.yml' 'redis.yml' 'local.yml'
do
  # Manual backup as the --backup option is not available for all versions of cp
  test -f "config/$file" && cp "config/$file" "config/$file~"
  cp "config/docker/$file" "config/$file"
done

sleep 120

script/reset_database.sh
DOCKER=true RAILS_ENV=test script/reset_database.sh

# The development database reset will do everything except run migrations for
# the test environment:
rails db:migrate
DOCKER=true RAILS_ENV=test rails db:migrate

# Set an easy password for the test user
rails runner 'User.first.update!(password: "password")'
