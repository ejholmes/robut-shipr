# Robut Shipr

A Robut plugin for [Shipr](http://github.com/ejholmes/shipr)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'robut-shipr'
```

Add it to your Chatfile:

```ruby
require 'robut/plugin/shipr'
Robut::Plugin.plugins << Robut::Plugin::Shipr
```

## Usage

* `@robut deploy app`
* `@robut deploy app to staging`
* `@robut deploy app#feature-branch to staging`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
