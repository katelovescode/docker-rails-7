#!/bin/bash

if test -f SCRIPT_README.md; then
  mv -f SCRIPT_README.md README.md
fi

# TODO: Make this non-duplicative, extract parameterizing logic
parameterize() {
  parameter_name="${1//[^a-zA-Z0-9]/_}"
  parameter_name=$(echo "$parameter_name" | sed -r 's/[_]+/_/g')
  parameter_name=$(echo "$parameter_name" | tr '[:upper:]' '[:lower:]')
  echo "$parameter_name"
}

directory=$(basename "$(pwd)")
default_name=$(parameterize "$directory")
if [ "$1" != "" ]; then
  app_name=$(parameterize "$1")
else
  app_name="$default_name"
fi

docker stop "$app_name"
docker stop "${app_name}_postgres"
docker rm "$app_name"
docker rm "${app_name}_postgres"
docker rmi "$app_name"
docker volume rm "${app_name}_pgdata"
docker network rm "$app_name"

# Use this block to define any files you *don't* want wiped out in the fresh start
find . \
  ! -name 'dockerized_rails.sh' \
  ! -name 'start_fresh.sh' ! -name '.' \
  ! -name '..' \
  ! -name '*README*' \
  ! -path './.git' \
  ! -path './.git/*' \
  -prune -print -exec rm -rf {} +
