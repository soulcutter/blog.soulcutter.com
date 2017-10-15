#!/bin/sh

# Convert CSS (in case it wasn't being autogenerated during dev)
bundle exec sass --style expanded sass/application.scss public/application.css

# Upload to server
scp -r public/* soulcutter@soulcutter.com:/srv/www