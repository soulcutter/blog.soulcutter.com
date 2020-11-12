---
layout: post
title:  "Ruby Refinements Have One Good Use Case"
date:   2020-11-11 12:00:00 -0500
categories: ruby programming
summary: "After 10 years of refinements I know of a single (rare) good use-case for them"
---

## Preface
This article is not going to explain what Ruby refinements are. I do not assume that all Rubyists know what they are - in the 10 years since they have been a part of Ruby, real life usages are astonishingly rare. If you _are_ aware that they exist, you still may not be at-all familiar with how they work. There are many good articles available to explain what Ruby refinements are: for a clear and concise explanation of how refinements work, I suggest [Starr Horne's article Understanding Ruby Refinements and Lexical Scope](https://www.honeybadger.io/blog/understanding-ruby-refinements-and-lexical-scope/). For a thorough explanation I recommend [the transcript of James Adam's RubyConf talk titled Why Is Nobody Using Refinements?](https://interblah.net/why-is-nobody-using-refinements). It's quite long and in a challenging format to read, but it covers pretty much _everything_ and offers some explanations for why Rubyists are not using them. Whether you commit to reading all that or not, the last paragraph of that transcript offers inspiration for this article:

> Please – make a little time to explore Ruby. Maybe you’ll discover something simple, or maybe something wonderful. And if you do, I hope you’ll share it with everyone.

## The One Good (Rare) Use Case

### Conversion Wrappers

Conversion Wrappers? What's that?

Okay, full disclosure, I do not believe there is an agreed-upon name for this concept. So that gives you an idea of how rare and unusual they are in the wild. I take the term Conversion Wrapper from [this article about Ruby Conversion Methods](https://www.rubyguides.com/2018/09/ruby-conversion-methods/). [Avdi Grimm's book Confident Ruby](https://avdi.codes/books/) spends several pages (sections 3.6 - 3.8) on this topic under the name "conversion functions." These exist in Ruby's standard library - for example [`Array()`](https://ruby-doc.org/core-2.7.2/Kernel.html#method-i-Array) is one that you're likely to see in real code. Avdi also wrote a nice short summation of how you might write your own in his article ["A Ruby Conversion Idiom"](https://avdi.codes/a-ruby-conversion-idiom/), but that's a pale comparison to what you'd find in Confident Ruby (which I highly recommend, and is practical for everyday work outside of this esoteric topic).

There's a good chance you've never written one yourself. There's a good chance you haven't encountered ones that others have written. You absolutely DO see Ruby's included conversion wrappers being used. Why do you think that is? Beyond the programmer-education aspect (having a name for this thing, and understanding it as an idiom), I have a hunch that there's ALSO a technical reason for which Ruby Refinements are the **only** solution.

Ruby's conversion wrappers are attached to `Kernel` and therefore are available in every scope. Try running this snippet to illustrate:

{% highlight ruby %}
BAR = Array(1)
class Foo
   def self.bar; Array(1); end
   def bar; Array(1); end
end

BAR # => [1]
Foo.bar # => [1]
Foo.new.bar # => [1]
{% endhighlight %}

When writing our OWN conversion wrappers they are likely to look something like this contrived example:

{% highlight ruby %}
require 'time'

Timestamp = Struct.new(:at)

module Conversions
  module_function
  def Timestamp(value)
    return value if value.is_a?(Timestamp)
    Timestamp.new(value)
  end
end
{% endhighlight %}

You'll find that using a conversion wrapper in this form is more-painful than `Array()`:

{% highlight ruby %}
# BUSINESS = Timestamp(1) is not possible
# this works, but forces you to reference the namespace 
BUSINESS = Conversions.Timestamp(1)

class SeriousBusiness
  include Conversions
  extend Conversions
  
  def self.business; Timestamp(1); end
  def business; Timestamp(1); end
end
{% endhighlight %}

I concede - assigning a constant is not a compelling case. Having to `include` AND `extend` is a bit unusual, though. Let's fix that.

{% highlight ruby %}
# assuming the previously-defined Conversions module
class Conversions
  # whenever you `include` this module, also `extend` it
  def self.included(base); super; base.extend(self); end
end

class SillyBusiness
  include Conversions
  
  def self.business; Timestamp(1); end
  def business; Timestamp(1); end
end
{% endhighlight %}

The ergonomics of using that is a bit better, though it starts littering methods in more places. One subtle thing I will point out about using `module_function` - it hides the `Timestamp` method, but it IS there.

{% highlight ruby %}
SillyBusiness.Timestamp(1) # NoMethodError: private method `Timestamp' called for SillyBusiness:Class
SillyBusiness.new.Timestamp(1) # NoMethodError: private method `Timestamp' called for #<SillyBusiness:0x00007fcb712c0800>
SeriousBusiness.send(:Timestamp, 1) # ok, nobody will ever do this but it works because the method IS there
{% endhighlight %}

### Using Refinements for Conversion Wrappers

Let's check out what the refinement approach looks like and why I consider it the best way to implement conversion wrappers.

{% highlight ruby %}
module TimestampConversionRefinement
  refine Kernel do
    def Timestamp(value)
      return value if value.is_a?(Timestamp)
      Timestamp.new(value)
    end
  end
end

class ElegantBusiness
  using TimestampConversionRefinement
  
  def self.business; Timestamp(1); end
  def business; Timestamp(1); end
end

# ElegantBusiness.Timestamp(1) # NoMethodError: undefined method `Timestamp' for ElegantBusiness:Class
# ElegantBusiness.send(:Timestamp, 1) # NoMethodError: undefined method `Timestamp' for ElegantBusiness:Class
{% endhighlight %}

If you move `using TimestampConversionRefinement` to be outside of `ElegantBusiness` in the same file, you also have access to use it to define a constant with that same non-namespaced `Timestamp()` syntax because of the lexical scope of refinements. Whatever scope you decide to put `using TimestampConversionRefinement` it will NEVER pollute any lexical scope outside of that. You get the convenient behavior of a method defined on `Kernel`, but without affecting every other file or any gem dependency as you might have if you were to `Kernel.include(Conversions)`.

## Is it worth it?

**The refinement version of conversion wrappers is a superior technical approach that cannot be achieved any other way in Ruby.** The advantages are subtle, however, and unlikely to change the behavior of application code. Even if it is TECHNICALLY superior, code needs to expressive and understandable to people. People who at this point are unfamiliar with refinements in practice. Refinements themselves present a significant hurdle to adoption by virtue of their limitations and overall introduction of conceptual complexity. So it's a tough sell to recommend this for anything outside of personal projects or places with incredibly strong esoteric Ruby knowledge (like, say, hidden away within Rails).

## Popularizing this as idiomatic
There is ONE thing that MIGHT help grow some small foothold of adoption is: actually using refinements in Ruby's standard library! I would not at-all suggest ripping out what Ruby gives you on `Kernel` by default, but there are places in the standard library that pollute `Kernel` once you require them. One example is `BigDecimal`

{% highlight ruby %}
BigDecimal(1) # NoMethodError: undefined method `BigDecimal'

require 'bigdecimal'
BigDecimal(1) # => 0.1e1
{% endhighlight %}

Ruby's standard library COULD adopt a usage that looks more like

{% highlight ruby %}
require 'bigdecimal'
using BigDecimal::Conversion
BigDecimal(1) # => 0.1e1
{% endhighlight %}

This would start to familiarize people with the concept of refinements and using them for conversion wrappers. It's tough to imagine a path towards changing pre-existing examples of this in the stdlib such as `BigDecimal`, `URI`, `Pathname` and others, but there remain opportunities to write _new_ conversion wrappers for existing stdlib classes. I humbly suggest `Date()`, `DateTime()`, and `Time()` to start?

## Why is this the only good use?

Ok, you caught me, total clickbait. I can't TRULY make that claim. It IS the only one I have found. I do think there are other very specific places where this could be handy, but this is the only "general case" I have found. `Kernel` has some interesting properties that make it an attractive target for refinements.

I've heard-suggested that `ActiveSupport`, which does a ton of monkey-patching of core classes, would make potentially-nice refinements. I don't hold this opinion strongly, but I disagree with that idea. A big value proposition of ActiveSupport is that it is "omnipresent" and sets a new baseline for ruby behaviors - as such, being global really makes the most sense. I don't know that anyone would be pleased to sprinkle `using ActiveSupport` in all their files that use it - they don't even want to THINK about the fact that they're using it. Along those lines I have found that conversion wrappers are used rarely-enough that it might be ok to introduce a hurdle of needing to recognize that you want to use them by adding a sparse `using MyConversions` to files on an individual basis. I will say that distinction comes down to a matter of personal taste, but knowing that there's no widespread adoption of an `ActiveSupportRefinements` makes me feel that the community as a whole has similar feelings.

You might need to be convinced that Conversion Wrappers THEMSELVES are a worthwhile idea - fair enough. Read Confident Ruby! If it might help, I don't mind also sharing a [less-contrived example that I wrote for a library dealing with defining thresholds for monitoring](https://gist.github.com/soulcutter/9dcd3aa75274253df3a77f88eb0d6fc8). I'm both a little proud and a little ashamed of that one - if you read my own comment, I refactored 13 lines of code into 109 lines. But I digress.

## Aha, but I have a different great use case!

That's awesome! I'd love to hear more about it. If you've got an article I can link to, I'd be sure to put it in an addendum here. 
