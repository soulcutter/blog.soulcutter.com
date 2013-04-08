---
layout: post
title: "Default Hash Values (the RIGHT way)"
date: 2013-04-08 11:01
comments: true
categories:
 - ruby
 - stdlib
---

In [my recent post about default hash values](/blog/2013/default-hash-values/)
I was posting something I thought was pretty basic, and embarassingly I missed what
should have been obvious. [Right there in the documentation for
Hash](http://ruby-doc.org/core-2.0/Hash.html#method-c-new) is the best way to
initialize Hash keys on-demand:

```ruby
options = Hash.new {|hash, key| hash[key] = [] } # => {}
options[:key] # => []
options[:key] << 'thing' # => ["thing"]
options # => {:key=>["thing"]}
```

I know I must've seen this before, but I guess it never stuck with me. Thanks to
[@alindeman](http://twitter.com/alindeman), [@pete_higgins](https://twitter.com/pete_higgins),
and [@samphippen](http://twitter.com/samphippen) for straightening me out.

Is it better to be thought a fool than to open your mouth and remove all doubt? I
dunno, but this fool learned the RIGHT answer to the problem as well as a dose of
humility. I suppose that's worth something!