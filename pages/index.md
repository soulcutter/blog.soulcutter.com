---
title: Phlex — fast, object-oriented view framework for Ruby
---

# Introduction
Phlex is a framework for building fast, reusable, testable views in pure Ruby.

```ruby_example
example do |e|
  e.tab "nav.rb", <<~RUBY
    class Nav < Phlex::HTML
      def template
        nav(class: "main-nav") {
          ul {
            li { a(href: "/") { "Home" } }
            li { a(href: "/about") { "About" } }
            li { a(href: "/contact") { "Contact" } }
          }
        }
      end
    end
  RUBY

  e.execute "Nav.new.call"
end
```
