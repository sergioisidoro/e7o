# E7o - Finding dead languages 💀

If your rails app grows, it is normal that localization keys are left behind, stalled. 
Knowing which ones are being used is hard, especially when you have edge cases, error strings, etc.

This allows you to collect all the keys being used to a redis instance.

## Usage

```.rb
require "e7o"

E7o.configure do |config|
    config.redis_host = "redis://PASSWORD@HOST:PORT"
    config.enabled = true
end
```


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'e7o'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install e7o
```

## Aknowledgements 
This gem inherits a lot from [i18n-counter](https://github.com/paladinsoftware/i18n-counter), but because our requests were large, having one call per key lookup was too heavy, 
so we batched things into request sized pieces.

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
