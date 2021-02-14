#!/bin/sh
set -e

# Generate site with jekyll
rm -rf ./public
JEKYLL_ENV=production NODE_ENV=production bundle exec jekyll build -d ./public

# Upload to server
scp -r public/* soulcutter@soulcutter.com:/srv/www
