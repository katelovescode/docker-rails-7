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

## TODO

### Enhancements

- passwords & secrets management
- print the docker command (or maybe set an alias?) for each container to prevent having to manually edit the long command if the containers go down
- separate behavior for production & development; namely that right now there's no db password set for development or testing, and that production.rb is set to force_ssl false for the sake of using this exact image for development
- script confirmation dialogue saying this script handles rbenv or the default ruby, nodenv or the default node
- remove added dependencies that aren't essential for rails
- take in a target directory to install rails in
