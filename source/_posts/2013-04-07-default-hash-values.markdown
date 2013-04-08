---
layout: post
title: "Default Hash Values"
date: 2013-04-07 13:08
comments: true
categories:
- ruby
- stdlib
---

UPDATE: Most of the advice in this post is superceded by [the followup
which reflects the best solution for default hash values](/blog/2013/default-hash-values-the-right-way/).

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

Addendum
--------

I was reminded by [@samphippen](http://twitter.com/samphippen) and
[@pete_higgins](https://twitter.com/pete_higgins) that there is a way to prevent
mutations from affecting the default value, and that is to initialize your
hash with a block:

```ruby
options = Hash.new { [] }

options[:key] << 'thing'
options[:key] # => []
options[:unknown] # => []
options # => {}

options[:key] += ['thing']
options[:key] += ['other thing']
options # => {:key=>["thing", "other thing"]}
```

As you can see there is still a potential bug lurking above where we never
actually assign a value to the hash key, however instead of returning a
mutated instance for missing values what you get is the result of evaluating
the block that is passed into the hash initializer.

In the scheme of things this is a better solution for initializing a hash
with a default value since the default will never get polluted by accidental
mutations on the default object.
