---
layout: post
title: "Click events in poltergeist vs capybara-webkit"
date: 2013-02-18 19:04
comments: true
categories:
- testing
- javascript
- ajax
- ruby
---

Due to constraints from a continuous integration service that I am using, I found
myself converting from [capybara-webkit](https://github.com/thoughtbot/capybara-webkit)
to [poltergeist](https://github.com/jonleighton/poltergeist) for my headless
javascriptable feature testing needs. To capybara's credit, the driver change is
as simple as `Capybara.javascript_driver = :poltergeist`

Unfortunately I discovered that after this simple substitution some of my features
involving asynchronous requests began to fail intermittently. By
[taking screenshots](https://github.com/jonleighton/poltergeist#taking-screenshots)
of the points of failure I discovered that calls to `find(selector).click` did not
always appear to trigger JavaScript click events.

I cannot say whether the root cause has to do with element visibility, CSS
animations, or the JavaScript callbacks not being registered in time for the clicks
to trigger them, however I -did- find that switching to
`find(selector).trigger('click')` solved my problem.

Somewhat annoying considering this behavior "just worked" in capybara-webkit, but
I suppose I'll have to live with it for now.