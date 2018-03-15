---
layout: post
title:  "Memoizing in Ruby"
date:   2018-03-14 12:00:00 -0500
categories: ruby
---

Memoization is the pattern of calculating a value once, and re-using that value each subsequent time it is needed.
It's common to encounter this in Ruby in the form `@variable ||= calculation`. It's so common that it
is often used even where it's not expensive or re-used; it's become a part of idiomatic Ruby. In my
[last post](/articles/local-variable-aversion-antipattern.html) I made an off-hand reference to solving the problem
of using memoization for *falsy* values, and it seems a topic worth talking about in and of itself.

## What do you mean there's a problem?

Consider that the following methods have the same behavior:

{% highlight ruby %}
def foo_or_equal
  @foo ||= calculate_foo
end

def foo_verbose
  @foo || (@foo = calculate_foo)
end

def foo_multiline
  return @foo if @foo
  @foo = calculate_foo
end
{% endhighlight %}

When `calculate_foo` returns a *truthy* object - anything but `nil` or `false` - there's no problem at all. Calling any
one of those methods repeatedly will result in `calculate_foo` only being called
once<sup><small>[&dagger;](#footnotes)</small></sup>.

When `calculate_foo` returns a *falsy* object - `nil` or `false` - it stores that value. Every subsequent call will
invoke `calculate_foo` another time and re-store the falsy value. If that calculation is expensive - makes a database
call, communications with an external API, or is otherwise-slow - then this is precisely the behavior that memoization
was intended to prevent (but didn't).

## The foolproof way to memoize

Now that we've identified the problem, how about a solution?

{% highlight ruby %}
def foo_foolproof
  return @foo if defined?(@foo)
  @foo = calculate_foo
end
{% endhighlight %}

That's all there is to it. Calling `defined?(@foo)` checks whether the expression `@foo` exists, though it is a bit
special since it *does not actually evaluate the expression*. It looks like a method, but is actually a Ruby keyword.
An alternative that uses a regular Ruby method is `instance_variable_defined?(:@foo)`, but it's a bit verbose. And
that's actually the drawback to this foolproof approach in general. While it works the intended way and memoizes *falsy*
values, it's longer, more-boilerplate, and less-readable.

## How about a generalized approach?

Here's a potential way to address this:

{% highlight ruby %}
class Memoizer < Module
  def initialize(method)
    define_method(method) do
      ivar = "@#{method}"
      return instance_variable_get(ivar) if instance_variable_defined?(ivar)
      instance_variable_set(ivar, super())
    end
  end
  
  module Helper
    def memoize(method)
      prepend Memoizer.new(method)
    end
  end
end

class Foo  
  extend Memoizer::Helper
  def foo
    calculate_foo # this may as well be in-lined rather than a separate method
  end
  memoize :foo
end
{% endhighlight %} 

It's worth pointing out that this approach only handles memoizing methods with no arguments. This could be adapted in
order to handle arguments - in fact you can find some links in this articles footnotes that go into that.

There are several RubyGems that do this - and *of course* `ActiveSupport` [once had a memoizing module](https://github.com/rails/rails/commit/36253916b0b788d6ded56669d37c96ed05c92c5c#activesupport/lib/active_support/memoizable.rb),
but I pretty much agree with the conclusion of the Rails team there, which is to say - it's better to just use Ruby in
your own projects. It's faster, it's clearer, there's *no need for a dependency* to do this. I'd even say this proposed
helper is overkill. The point was to show that it's simple, and it's something you *can* do if it makes your code clearer
or easier to work with.

#### Footnotes

&dagger; - this is not strictly true in a multi-threaded environment, but I'm choosing to avoid getting into that in this
article.

This article is *nothing new* and [has](https://www.justinweiss.com/articles/4-simple-memoization-patterns-in-ruby-and-one-gem/)
[been](http://gavinmiller.io/2013/advanced-memoization-in-ruby/) [written](http://blog.honeybadger.io/rubyist_guide_to_memoization/)
[about](https://engineering.gusto.com/memoization-in-ruby-made-easy/)
[before](https://karolgalanciak.com/blog/2017/05/28/ruby-memoization-%7C%7C-equals-vs-defined-syntax/), but it's a common-enough
footgun that I didn't mind writing up my version of this sentiment.
