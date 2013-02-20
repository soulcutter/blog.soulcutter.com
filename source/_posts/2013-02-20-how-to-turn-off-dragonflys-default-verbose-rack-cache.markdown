---
layout: post
title: "How to turn off Dragonfly's default verbose rack-cache"
date: 2013-02-20 10:20
comments: true
categories:
- ruby
- rack
- testing
---

It was a minor annoyance that my feature specs were incredibly verbose,
filling my console with rack-cache trace debugging information like so:

```
cache: [GET /assets/logo.jpg] miss, store
cache: [GET /assets/bg-nav.jpg] miss, store
cache: [GET /assets/bg-box.jpg] miss, store
```

I tracked it down to the fact that [Dragonfly](https://github.com/markevans/dragonfly)'s
default configuration adds [rack-cache](https://github.com/rtomayko/rack-cache) to your
middleware stack [configured with verbose logging enabled](http://rtomayko.github.com/rack-cache/configuration).

My solution was to add a block in my Dragonfly initializer to remove that noisy
rack-cache and insert my own quiet version.

```ruby config/initializers/dragonfly.rb
require 'dragonfly/rails/images'

app = Dragonfly[:images]

# some storage settings here...

# shuts down verbose cache logging
if %w(development test).include? Rails.env
  Rails.application.middleware.delete(Rack::Cache)

  Rails.application.middleware.insert 0, Rack::Cache, {
    :verbose     => false, # this is set to true in dragonfly/rails/images
    :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded in case of spaces
    :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")
  }
end
```

Now my testing serenity is unperturbed by extra logging noise.
