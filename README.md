# FeishuApi  [![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fatrox%2Fsync-dotenv%2Fbadge&label=build&logo=none)](https://actions-badge.atrox.dev/atrox/sync-dotenv/goto)


FeishuApi is an integration of commonly used feishu open platform's APIs, easy to call.


English | [简体中文](./README-zh.md)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add feishu-api

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install feishu-api

## Roadmap
- ✅ Messenger
- ✅ Group
- Docs
- Calendar
- Video Conferencing
- Rooms
- Attendance
- Approval
- Account
- Console
- Task
- Email
- App Information
- Company Information
- Search
- AI
- Admin
- HR
- OKR
- Real-name authentication
- Smart access control
- Enterprise Encyclopedia
- Contacts

## Documentation
See detailed documentation at [feishu-api-doc](https://xiemala.com/s/DstEGj/feishu-api)
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
