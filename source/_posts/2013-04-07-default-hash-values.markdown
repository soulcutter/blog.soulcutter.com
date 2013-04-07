---
layout: post
title: "Default Hash Values"
date: 2013-04-07 13:08
comments: true
categories:
- ruby
- stdlib
- beginner
---

If you ever find yourself writing initialization for ruby hash values that
looks something like this:

```ruby
options = {}
options[:key] ||= []
options[:key] << 'thing'
options[:key] << 'other thing'
options # => {:key=>["thing", "other thing"]}
```

You can save yourself the `||=` statement by initializing your hash with a default value.

```ruby
options = Hash.new []
options[:key] += ['thing']
options[:key] += ['other thing']
options # => {:key=>["thing", "other thing"]}
```

One small caveat is that accessing a hash at an unknown key will return
the exact instance that you gave to your `Hash` initializer. If it's a mutable object
such as the `Array` in this example, then mutating the object for an unknown key
will change the value for ALL unknown keys.

```ruby
options = Hash.new []
options[:key] << 'thing'
options[:key]     # => ['thing'] great!
options[:unknown] # => ['thing'] umm, this is unexpected
options           # => {} we never assigned a value to our hash key at all!
```

So go forth and use default hash values! Just be mindful to avoid changes to the
default value object.
