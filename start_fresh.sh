#!/bin/bash

if test -f SCRIPT_README.md; then
  mv SCRIPT_README.md README.md
fi
find . ! -name 'dockerized_rails.sh' ! -name 'start_fresh.sh' ! -name '.' ! -name '..' ! -name '*README*' ! -path './.git' ! -path './.git/*' -prune -print -exec rm -rf {} +
