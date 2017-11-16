---
layout: post
title:  "Instrumenting Ruby Methods"
date:   2017-11-16 12:00:00 -0500
categories: ruby 
---
**Instrumentation** is the addition of measurement to code - for example timing how long Ruby is spending in a given
method. There are many approaches to adding instrumentation to code
in Ruby - whether it's using 3rd party services like New Relic and Datadog, using libraries like Rubyprof, or even plain
old logging. Here I propose an unintrusive Ruby 2.0+ technique to add instrumentation to arbitrary methods without
monkeypatching. If you want to jump to the proposed code without the explanation of how or why we got there, here's
your [TLDR](#tldr).

### Instrumenting Code Directly Is Messy
One thing that bothers me when adding custom instrumentation to code is how intrusive it can be. Sometimes the code
necessary to add measurements around a process are more code than the process itself. If you intertwine the
instrumenting code with the code that it's intended to measure, it obscures the intent of the original code.

### Coupling
If you use a library for instrumentation, and add that instrumentation to code all over your codebase, it can quickly
turn into a broad but shallow coupling to that library. For example imagine that you started a project using New Relic
and it grew to a point where there were dozens of custom calls to New Relic's instrumentation - so far so good. What if
you stop using New Relic in the future? Or if the instrumentation API changes? Or you notice a subtle bug in the
boilerplate instrumenting code you've sprinkled everywhere? Now you have dozens of files to modify in order to get
instrumentation working properly again.
 
### Not Convinced?
If you've made it this far, you may be thinking *"Well that's just great. Instrumenting is useful, but don't add 
instrumentation directly to the code. So what ARE you supposed to be doing?!"* So let's dive into real code example to
illustrate.

{% highlight ruby %}
class Sleeper
  def sleep
    Kernel.sleep 1
  end
  
  def deep_sleep
    Kernel.sleep 2
  end
end
{% endhighlight %}

OK, we have a contrived example! Now let's add some instrumentation!

Here's an example of what New Relic instrumentation might look like.

{% highlight ruby %}
class Sleeper
  extend ::NewRelic::Agent::MethodTracer

  def sleep
    value = nil
    self.class.trace_execution_scoped(['sleep']) do
      value = Kernel.sleep 1
    end
    value
  end
  
  def deep_sleep
    value = nil
    self.class.trace_execution_scoped(['deep_sleep']) do
      Kernel.sleep 2
    end
    value
  end
end
{% endhighlight %}

There's a lot of repetition in there, but also this add methods to the Sleeper class and there are New
Relic-specific method calls alongside the code that's being instrumented.

Let's revert back to the original implementation of `Sleeper`. How might we be able to add instrumentation WITHOUT
changing the `Sleeper` class? Here's a first pass:

{% highlight ruby %}
module InstrumentedSleep
  def sleep
    value = nil
    self.class.trace_execution_scoped(['sleep']) { value = super }
    value
  end
  
  def prepended(klass)
    klass.extend ::NewRelic::Agent::MethodTracer unless klass.is_a?(::NewRelic::Agent::MethodTracer)
  end
end

module InstrumentedDeepSleep
  def deep_sleep
    value = nil
    self.class.trace_execution_scoped(['deep_sleep']) { value = super }
    value
  end
  
  def prepended(klass)
    klass.extend ::NewRelic::Agent::MethodTracer unless klass.is_a?(::NewRelic::Agent::MethodTracer)
  end
end

Sleeper.prepend InstrumentedSleep
Sleeper.prepend InstrumentedDeepSleep
{% endhighlight %}

### Why prepend?

Prepending gives us a way to insert our module in the method lookup chain. When you call `Sleeper.sleep` it will resolve
which `sleep` method to execute in the order of its `ancestors` array. [Prepend puts a module first in the ancestor
list](https://medium.com/@leo_hetsch/ruby-modules-include-vs-prepend-vs-extend-f09837a5b073),
before even the Class itself. The order of resolving methods in this example will then will be:

1. InstrumentedDeepSleep
1. InstrumentedSleep
1. **Sleeper**
1. Object
1. Kernel
1. BasicObject 

If you had used `include`, the order of the ancestry, and how Ruby would attempt to resolve the method being called
would look more like this:

1. **Sleeper**
1. InstrumentedDeepSleep
1. InstrumentedSleep
1. Object
1. Kernel
1. BasicObject

Also worth noting that we used the `prepended` hook to extend the New Relic code 

### It's a lot of work to create a Module per method  

The only difference between the `Instrumented` modules is the name of the method to instrument. If only there was a way
to write a template for this type of `Module`, and generate a new module every place we want to instrument. It
so-happens there IS a handy way to do that - enter the
[Module Builder pattern](dejimata.com/2017/5/20/the-ruby-module-builder-pattern).

{% highlight ruby %}
class Intrumentation < Module
  def initialize(method)
    @method = method
    
    define_method(method) do |*args, &block|
      value = nil
      self.class.trace_execution_scoped([@method]) { value = super(*args, &block) }      
      value      
    end    
  end
  
  def prepended(klass)
    klass.extend ::NewRelic::Agent::MethodTracer unless klass.is_a?(::NewRelic::Agent::MethodTracer)
  end
end

Sleeper.prepend Instrumentation.new(:sleep)
Sleeper.prepend Instrumentation.new(:deep_sleep)
{% endhighlight %}

Not bad! Now we don't have to define a `Module` for every method - the `Instrumentation` class will build modules for
us based on the template we've provided.

You may have noticed a tweak that was made to the invocation of `super` - because we are using the block form of
`define_method` we must call `super` with arguments rather than the implied arguments of a bare call to `super`. If you
try using a plain `super` Ruby will correct you with an error message. It's just the way it is - *for reasons*, I
assume.

### Making this more-usable

In terms of usability, I think there are a couple of rough edges here. First-off, despite it being a language feature,
a lot of people don't think to `prepend` modules, and even if it did make sense to a person it's not-so-natural to
`prepend` a module/class that you instantiate. Maybe I'm too pessimistic about what folks are comfortable with?
Lastly, how would you be able to apply this to a Class method? It IS possible, but it's not obvious.

A more-polished
interface might look like this:

<a id="tldr"/>
{% highlight ruby %}
module Instrumentor
  def self.instrument_method(klass, method, label="#{klass.name}.#{method}")
    unless klass.respond_to?(method)
      raise ArgumentError, "#{klass.name} does not define #{method} - unable to instrument #{label.inspect}"
    end
    klass.prepend Instrumentation.new(method, label)
  end
  
  def self.instrument_class_method(klass, method, label="#{klass.name}##{method}")
    instrument_method(klass.singleton_class, method, label)
  end

  class Intrumentation < Module
    def initialize(method, label)
      @method = method
      @label = label
    
      define_method(method) do |*args, &block|
        value = nil
        self.class.trace_execution_scoped([@label]) { value = super(*args, &block) }      
        value      
      end    
    end
    
    def inspect
      klass = self.class.name || self.class.inspect
      "#<#{klass}: method=#{@method.inspect} label=#{@label.inspect}>"
    end

    def prepended(klass)
      klass.extend ::NewRelic::Agent::MethodTracer unless klass.is_a?(::NewRelic::Agent::MethodTracer)
    end
  end
end

Instrumenter.instrument_method(Sleeper, :sleep)
Instrumenter.instrument_method(Sleeper, :deep_sleep)
Instrumenter.instrument_class_method(Sleeper, :new)
{% endhighlight %}

The way we are able to wrap class methods is to pass `klass.singleton_class` as the class used for prepending the
instrumentation module.

I added some other niceties, such as the `inspect` method which is helpful for describing the module if you look at
a class's `ancestors`. You may not do that explicitly a lot, but it does come up - for example you might see this in
a `pry` console when you do `ls Sleeper`.

There's also now an arbitrary label that can be used for the instrumentation, with some useful defaults. No need
to justify that technically-speaking, it's just nice to have!

### There you have it

This presents a friendly API, doesn't infest the code that is being instrumented,
doesn't pollute the instrumented code's interface, captures the pattern of instrumention unique to your project
in a single place, and is easy to change when your instrumentation strategy changes.

