# README

This script is what I use on my local machine to spin up a Rails app with postgres in docker containers. It requests an app name (defaults to the directory it's in), a Ruby version (defaults to 3.2.3), and a Node version (defaults to 20.12.2).

The script comments should cover documentation for each step, but of note is the following:

- Homebrew is required
- `nodenv` and `rbenv` are supported, but optional
- If you don't have `nodenv` or `rbenv`, the script will attempt to install the ruby and node versions you've specified on the bare machine. YMMV because I have the env managers installed and didn't test on an environment without them. Open for PRs if you're able to test and there need to be changes.
- `yq` (YAML parsing package) will be installed as a part of this script
- the `rails new` command is run in the same directory the script is in, and it sets up `esbuild` and `postcss`, and removes `minitest` as I prefer rspec. If you want another configuration, you'll want to edit the line w/ `rails new` about halfway through the script
- the script makes a few git commits to commit your progress after a couple configuration changes for rails

Once you've run the script, if your containers are stopped, you will need to run the whole docker command for each container again, and due to the variable substitution in the script it will be hard to copy-paste without manually typing in the app name you chose. In upcoming versions, I will output the docker command at the end of the script, and later, create a docker-compose to make this better.

## USAGE

```sh
git clone git@github.com:katelovescode/docker-rails-7.git [/path/to/your/app/directory]
sh dockerized_rails.sh
```

The script will prompt you for the mode you'd like to run it in; enter the number indicating your preference:

1. **`Create Rails App` mode** is intended for spinning up a working Dockerized Rails instance ready for development, and it will do what it says on the tin; create a new rails app and spin up the docker containers.
2. **`Develop Script` mode** is intended for developing on the script itself. It will create a new Rails app, spin up the docker containers and then prompt you if you'd like to destroy the Rails app itself. The way I use it is that I leave the prompt open while I dig around in the app and make sure everything is configured how I want, make any necessary changes to the script, and then go back to the prompt and enter `y` to destroy the Rails app directories or `n` if you want to keep them. _**NOTE: This doesn't destroy the docker images or containers, that will need to be done manually.**_

If you decide that you want to start over at any time, `sh start_fresh.sh` is a convenience script to revert the repository back to its original state (that's what `Develop Script` mode does when you enter `y`)

## NOTES ON DEVELOPMENT

Just keeping notes here for myself; as I develop on the script, best/easiest development practice is probably to do the following:

```bash
git checkout -b new_feature
# make changes to script(s), etc.
git add . && git commit -m "I made these cool changes"
sh dockerized_rails.sh
# leave prompt for deletion open without answering
# check to see if everything works as expected
# if so, respond "y" to the deletion script
# if any lingering artifacts are present:
git reset --hard
```

## TODO

### Enhancements

- passwords & secrets management
- print the docker command (or maybe set an alias?) for each container to prevent having to manually edit the long command if the containers go down
- separate behavior for production & development; namely that right now there's no db password set for development or testing, and that production.rb is set to force_ssl false for the sake of using this exact image for development
- script confirmation dialogue saying this script handles rbenv or the default ruby, nodenv or the default node
- remove added dependencies that aren't essential for rails
- take in a target directory to install rails in
- automate tearing down the docker configuration when starting fresh

###### TODO for Development

Currently, development container can't find postgres - I tried changing to port 5431 in the db config (see the dockerized_rails port mapping on the run commands for postgres) but that didn't work either. This is the next step to fix.
