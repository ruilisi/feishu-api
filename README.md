# FeishuApi

FeishuApi is a integration of commonly used feishu open platform's APIs, easy to call.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add feishu-api

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install feishu-api

## Usage

Add feishu-api.rb in config/initializers

```ruby
 FeishuApi.configure do |config|
   config.app_id = ''
   config.app_secret = ''
 end
```

Example:

```ruby
FeishuApi.send_text_by_group('oc_xxx', 'hello')
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ruilisi/feishu-api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ruilisi/feishu-api/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FeishuApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ruilisi/feishu-api/blob/master/CODE_OF_CONDUCT.md).
