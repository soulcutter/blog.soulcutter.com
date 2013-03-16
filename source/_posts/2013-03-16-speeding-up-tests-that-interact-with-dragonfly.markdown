---
layout: post
title: "Speeding up tests that interact with Dragonfly"
date: 2013-03-16 09:43
comments: true
categories:
- ruby
- testing
---

I noticed that my rspec tests which interacted with
[Dragonfly](https://github.com/markevans/dragonfly) attachments on my models
were slowing down my test suite. Without even profiling I could see in my
terminal menu bar that running these specs was resulting in system calls to
ImageMagick `convert` and `identify` commands.

This seemed entirely unnecessary to me in a test environment, so I came up
with this small monkeypatch to bypass Dragonfly's typical calls out to
ImageMagick:

```ruby spec/support/dragonfly.rb
module Dragonfly
  module ImageMagick
    module Utils

      private

      # does not run actual ImageMagick conversion, just returns the same temp object
      def convert(temp_object=nil, *_)
        temp_object
      end

      def identify(*_)
        # this is totally arbitrary
        { format: :png, width: 300, height: 250, depth: 8 }
      end
    end
  end
end
```

YMMV, but this resulted in a pretty significant speed increase in my image-centric
application - on the order of 2x faster! Good times.