---
layout: post
title: "Localization of nested attributes in Rails 3.2"
date: 2013-02-16 13:05
comments: true
categories: 
- Rails
- i18n
---

When you refer to one shared model from a handful of other models, sometimes
you need to give the shared model's attributes different user-facing names
since they are being used in a different context. Unfortunately the
[documentation for using Rails' built-in localization](http://guides.rubyonrails.org/i18n.html#translations-for-active-record-models)
does not indicate how to accomplish this feat.

Fear not, there is a way!

If you can look past a contrived example, let's say you've got models for
`Organization` and `Customer`, and each of them refer to a `ContactInfo`.
The unnested way to use Rails i18n would be something like this:

```yaml config/locales/en.yml
en:
  activerecord:
    attributes:
      contact_info:
        phone: Phone number
```

```ruby
ContactInfo.human_attribute_name("phone") # => "Phone number"
```

To show different strings for Organization and Customer, the yaml syntax
has a slight twist - rather than nesting `contact_info` inside of
`organization` or naming they key `organization.contact_info`
the nested attribute should be separated with a `/` character.

```yaml config/locales/en.yml
en:
  activerecord:
    attributes:
      organization/contact_info:
        phone: Customer service number
      customer/contact_info:
        phone: Phone number
```

Despite the yaml syntax, the new call for a nested attribute with
`human_attribute_name` is dot-separated. Feels a little weird since
the yaml uses slashes, but there you have it.

```ruby
Organization.human_attribute_name("contact_info.phone") # => Customer service number
Customer.human_attribute_name("contact_info.phone") # => Phone number
```

I had a hard time tracking down this syntax through the documentation or
google, and [it appears that this worked differently pre-3.2](https://github.com/rails/rails/issues/1869).
This seems like it would be a good candidate for a Rails documentation
contribution.

