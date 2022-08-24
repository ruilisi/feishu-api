# FeishuApi [![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fatrox%2Fsync-dotenv%2Fbadge&label=build&logo=none)](https://actions-badge.atrox.dev/atrox/sync-dotenv/goto)

FeishuApi是飞书开放平台常用API的集成，易于使用。


[English](./README.md) | 简体中文

## 安装

安装gem，并通过执行以下命令添加到项目的Gemfile中：

    $ bundle add feishu-api

如果不使用bundler来管理依赖项，通过执行以下命令来安装gem：
    $ gem install feishu-api

## 开发路线
- ✅ 消息
- ✅ 群组
- 云文档
- 日历
- 视频会议
- 会议室
- 考勤打卡
- 审批
- 帐号
- 服务台
- 任务
- 邮箱
- 应用信息
- 企业信息
- 搜索
- AI能力
- 管理后台
- 飞书人事（标准版）
- 招聘
- OKR
- 实名认证
- 智能门禁
- 企业百科
- 通讯录

## 文档
请参考详细文档 [feishu-api-doc](https://xiemala.com/s/DstEGj/feishu-api)
## 使用

在 config/initializers 中添加 feishu-api.rb

```ruby
 FeishuApi.configure do |config|
   config.app_id = ''
   config.app_secret = ''
 end
```

使用样例:

```ruby
FeishuApi.send_text_by_group('oc_xxx', 'hello')
```

## 贡献

欢迎在[Github](https://github.com/ruilisi/feishu-api)上提交错误报告和合并请求。本项目旨在成为一个安全、开放的协作空间，贡献者应遵守[行为准则](https://github.com/ruilisi/feishu-api/blob/master/CODE_OF_CONDUCT.md)。

## 许可

本项目使用MIT许可. 在 [MIT](http://opensource.org/licenses/MIT) 查看完整文本。

## 行为守则 

在 FeishuApi 项目的代码库、问题跟踪器、聊天室和邮件列表中进行交互的每个人都应遵循 [行为准则](https://github.com/ruilisi/feishu-api/blob/master/CODE_OF_CONDUCT.md)。
