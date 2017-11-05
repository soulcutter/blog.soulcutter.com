#!/bin/sh
set -e

# Generate site with jekyll
rm -rf ./public
jekyll build -d ./public

# Upload to server
echo "scp -r public/* soulcutter@soulcutter.com:/srv/www"
