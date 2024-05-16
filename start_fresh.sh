#!/bin/bash

# Restore custom files
if test -f SCRIPT_README.md; then
  mv -f SCRIPT_README.md README.md
fi
if test -f Dockerfile.default; then
  mv -f Dockerfile Dockerfile.multistage
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
docker stop "${app_name}_development"
docker stop "${app_name}_postgres"
docker stop "${app_name}_postgres_development"
docker rm "$app_name"
docker rm "${app_name}_development"
docker rm "${app_name}_postgres"
docker rm "${app_name}_postgres_development"
docker rmi "$app_name"
docker rmi "${app_name}_development"
docker volume rm "${app_name}_pgdata"
docker volume rm "${app_name}_pgdata_development"
docker network rm "$app_name"
docker network rm "${app_name}_development"

# Use this block to define any files you *don't* want wiped out in the fresh start
find . \
  ! -name 'dockerized_rails.sh' \
  ! -name 'Dockerfile.multistage' \
  ! -name 'start_fresh.sh' ! -name '.' \
  ! -name '..' \
  ! -name '*README*' \
  ! -path './.git' \
  ! -path './.git/*' \
  -prune -print -exec rm -rf {} +
