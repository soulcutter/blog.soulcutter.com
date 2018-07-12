---
layout: post
title:  "Hiding .gemrc credentials in dotfiles"
date:   2018-07-12 12:00:00 -0500
categories: shell, dotfiles
---

I recently came across this problem with the `~/.gemrc` file used by the
[gem command](https://guides.rubygems.org/command-reference/) since I needed to store a
[a private token](https://gemfury.com/help/repository-url/) for accessing a GemFury gem source. I struggled to figure
out a way to keep the file in my dotfiles without exposing myself to the possibility that I would publish them. Finally,
at the end of my rope I reached out to my colleagues with this problem and within minutes
[Adam Strickland](https://github.com/adamstrickland) responded with a great approach that was not-obvious but ends up
being a great way to provide configuration outside of the committed `~/.gemrc` file. A true hidden gem.
--do you see what I did there?

## GEMRC: the environment variable

It turns out that you can specify another place for the
[gem command](https://guides.rubygems.org/command-reference/) to look for configuration. If you define `GEMRC`
in your shell to point to a file, it will shallow-merge the configuration in `~/.gemrc` with that file. The shallow
merge behavior is important - what I mean by that is any configuration key found in both places will be completely
overwritten by the value in the file `GEMRC` points to. More-concretely, if you define sources in both places you don't
end up with the union of all sources, you end up with whatever sources are defined in the `GEMRC` file.

Armed with that knowledge, I added this snippet to my shell initialization scripts:

{% highlight bash %}
if [ -f "${HOME}/.gemrc.local" ]; then
  export GEMRC="${HOME}/.gemrc.local"
fi
{% endhighlight %}

I manually moved all the sources, including the sources containing auth, to that file. Then I removed the sensitive
sources from my tracked `~/.gemrc` file, and boom I have my credentials working, but I also have a tracked file for
non-sensitive settings.

## How it works

I wanted to dig just a bit deeper in order to understand how this worked, because I found it -extremely- difficult to
find any reference to it across the internet. Trying to google GEMRC lands you with explanations of the "standard"
home directory file and not much else. There [was a stack overflow post](https://stackoverflow.com/questions/35048760/is-there-a-gemrc-local-or-equivalent)
that I finally dug up, and it DOES appear [in the docs](https://docs.ruby-lang.org/en/trunk/Gem/ConfigFile.html) if you
dig a fair amount. For me the best explanation of how it works is [in the source](https://github.com/rubygems/rubygems/blob/cbee1078e62f1cc167c6ebb91d2f97760394bac4/lib/rubygems/config_file.rb#L185-L187)
where you can see that it can be a colon or semicolon-separated list of files. It seems like an opportunity for a
documentation improvement - perhaps in [the RubyGems website FAQ](https://guides.rubygems.org/faqs/).

## TLDR;

You can define an environment variable `GEMRC` that points to a file that gets loaded in addition to system config or
user (home directory) config, and it will be loaded/merged after those other configs - totally useful for hiding sources
containing credentials if you commit your dotfiles to a public repository.

That's it! Cheers!
