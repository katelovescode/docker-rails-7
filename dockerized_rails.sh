#!/bin/bash

#######################
# Requirements
#######################
# homebrew

#######################
# Dependencies Added
#######################
# yq
# ruby
# node

# TODO: ENHANCEMENT
# remove added dependencies that aren't essential for rails

#######################
# Optional
#######################
# nodenv
# rbenv

# TODO: ENHANCEMENT
# Take in target directory to the script as a param

# TODO: ENHANCEMENT
# confirmation dialogue saying this script handles rbenv or the default ruby, nodenv or the default node
# if you have rbenv or nodenv this will work
# if you're using system ruby or node, no guarantees

# Move README so it won't be overwritten
mv README.md SCRIPT_README.md

# Install yq using homebrew, which for now is a required application
# TODO: ENHANCEMENT
# Install homebrew and/or find other installation methods
if which brew; then
  if ! which yq; then
    brew install yq
  fi
else
  echo "homebrew is required for this script, please install homebrew and run again"
  exit 1
fi

# Take in user's preferred app_name, defaults to the directory name
read -rp "Mode: Create Rails App (1) / Develop Script (2) [1]: " development_mode
development_mode=${development_mode:-1}
read -rp "App Name [$(basename "$(pwd)")]: " app_name
app_name=${app_name:-$(basename "$(pwd)")}
constant_app_name=$(echo "$app_name" | tr '[:lower:]' '[:upper:]')

# Take in user's preferred versions with defaults
read -rp "Ruby version [3.2.3]: " ruby_version
ruby_version=${ruby_version:-3.2.3}
read -rp "Node version [20.12.2]: " node_version
node_version=${node_version:-20.12.2}
read -rp "Yarn version [1.22.22]: " yarn_version
yarn_version=${yarn_version:-1.22.22}

echo "$ruby_version" >.ruby-version
echo "$node_version" >.node-version
echo "$yarn_version" >.yarn-version

if command -v rbenv &>/dev/null; then
  if ! rbenv versions | grep "$ruby_version"; then
    rbenv install "$ruby_version"
  fi
# if nodenv is not installed, install latest version with brew
# TODO: ENHANCEMENT
# Install homebrew and/or find other installation methods
else
  if ! which ruby || ! ruby -v | grep "$ruby_version" && which brew; then
    brew install "ruby@${ruby_version}"
  fi
fi

# if nodenv is installed, check for this version and install it if it doesn't exist
if command -v nodenv &>/dev/null; then
  if ! nodenv versions | grep "$node_version"; then
    nodenv install "$node_version"
  fi
# if nodenv is not installed, install this major version with brew (I'm not sure if you can do minor versions)
# TODO: ENHANCEMENT
# Install homebrew and/or find other installation methods
else
  major_version=$(echo "$node_version" | cut -d '.' -f1)
  if ! which node || ! node -v | grep "$node_version" && which brew; then
    brew install "node@${major_version}"
  fi
fi

# install bundler and rails
gem install bundler rails

# install yarn
npm install -g yarn

# set yarn version
yarn set version "$yarn_version"

# initiate rails w/ postgres, esbuild, postcss
rails new . -f -n "$app_name" -d postgresql -j esbuild -c postcss -T

# The rest of this script assumes that `rails new` creates a database.yml with the following production configuration:
#
# production:
#   <<: *default
#   database: [app_name]_production
#   username: [app_name]
#   password: <%= ENV["[APP_NAME]_DATABASE_PASSWORD"] %>
#
# If versions of Rails after 7 change how this is done, this script won't work anymore

# edit the default database configuration to include the host we need to connect rails to the postgres container
host="<%= ENV[\"${constant_app_name}_DATABASE_HOST\"] %>" yq -i '.default.host = strenv(host)' config/database.yml

# TODO: ENHANCEMENT
# conditionally do this on localhost only, and/or replace dockerfile/build for local dev, maybe a second script
# turn off forced ssl
sed -i -e 's/config.force_ssl = true/config.force_ssl = false/g' config/environments/production.rb

# create the network
docker network create "$app_name"

# initiate a data volume
docker volume create "${app_name}_pgdata"

docker run -d \
  --name "${app_name}_postgres" \
  --network "$app_name" \
  --network-alias "${app_name}_postgres" \
  -v "${app_name}_pgdata":/var/lib/postgresql/data \
  -p 5432:5432 \
  -e POSTGRES_USER="${app_name}" \
  -e POSTGRES_DB="${app_name}_production" \
  -e POSTGRES_PASSWORD=password \
  postgres
# TODO: ENHANCEMENT
# configure passwords/secrets

docker build \
  --build-arg="RUBY_VERSION=$ruby_version" \
  --build-arg="NODE_VERSION=$node_version" \
  --build-arg="YARN_VERSION=$yarn_version" \
  -t "$app_name" \
  .

docker run -d \
  --name "$app_name" \
  --network "$app_name" \
  --network-alias "${app_name}_app" \
  -p 3000:3000 \
  -e RAILS_MASTER_KEY="$(cat ./config/master.key)" \
  -e "${constant_app_name}_DATABASE_HOST"="${app_name}_postgres" \
  -e "${constant_app_name}_DATABASE_PASSWORD"=password \
  "$app_name"
# TODO: ENHANCEMENT
# configure passwords/secrets

if [ "$development_mode" = 2 ]; then
  read -rp "Destroy Rails app files to commit the script? [y]: " destroy
  destroy=${destroy:-y}

  if [ "$destroy" = "y" ]; then
    /bin/bash ./start_fresh.sh
  fi
fi
