#!/bin/sh
set -e

# Generate site with jekyll
rm -rf ./public
bundle exec jekyll build -d ./public

# Upload to server
#scp -r public/* soulcutter@soulcutter.com:/srv/www
rsync -a ./public/ soulcutter@soulcutter.com:/srv/www/
