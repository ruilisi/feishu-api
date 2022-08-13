# frozen_string_literal: true

module FeishuApi
  class << self
    API_HOST = 'https://open.feishu.cn/open-apis'

    API_TENANT_ACCESS_TOKEN = '/auth/v3/tenant_access_token/internal'
    API_APP_ACCESS_TOKEN = '/auth/v3/app_access_token/internal'
    API_SEND_MESSAGES = '/im/v1/messages'
    API_CUSTOM_BOT_SEND = '/bot/v2/hook'

    def api(interface)
      "#{API_HOST}#{interface}"
    end

    def post(url, data, headers = {}, timeout = 30)
      HTTParty.post(api(url),
                    body: data.to_json,
                    headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }.merge(headers),
                    timeout: timeout,
                    verify: false)
    end

    def post_with_token(url, data, _timeout = 30)
      headers = { Authorization: "Bearer #{tenant_access_token}" }
      post(url,
           data,
           headers)
    end

    def tenant_access_token
      Rails.cache.fetch('tenant_access_token', expires_in: 2.hours) do
        res = post(API_TENANT_ACCESS_TOKEN, {
                     app_id: Config.app_id,
                     app_secret: Config.app_secret
                   })

        return nil if res.code != 200

        body = JSON.parse(res.body)
        token = (body['code']).zero? ? body['tenant_access_token'] : nil
        token
      end
    end

    def app_access_token
      Rails.cache.fetch('app_access_token', expires_in: 2.hours) do
        res = post(API_APP_ACCESS_TOKEN, {
                     app_id: Config.app_id,
                     app_secret: Config.app_secret
                   })
        return nil if res.code != 200

        body = JSON.parse(res.body)
        token = (body['code']).zero? ? body['app_access_token'] : nil
        token
      end
    end

    # 发送消息
    def send_message(receive_type, receive_id, msg_type, content)
      res = post_with_token("#{API_SEND_MESSAGES}?receive_id_type=#{receive_type}",
                            { receive_id: receive_id, msg_type: msg_type, content: content })
      return nil if res.code != 200

      JSON.parse(res.body)
    end

    # 发消息到指定群聊
    def send_message_by_group(receive_id, msg_type, content)
      send_message('chat_id', receive_id, msg_type, content)
    end

    # 发文本消息到指定群聊
    def send_text_by_group(receive_id, text)
      send_message_by_group(receive_id, 'text', JSON.generate({ text: text }))
    end

    # 通过邮箱识别用户, 发消息到指定用户
    def send_message_by_email(receive_id, msg_type, content)
      send_message('email', receive_id, msg_type, content)
    end

    # 自定义机器人接口 发送消息
    def custom_robot_send(data, hook_id)
      post("#{API_CUSTOM_BOT_SEND}/#{hook_id}", data)
      return nil if res.code != 200

      JSON.parse(res.body)
    end

    # 自定义机器人接口 发送文本消息
    def custom_robot_send_text(text, hook_id)
      custom_robot_send({
                          msg_type: 'post',
                          content: {
                            post: {
                              'zh-CN': {
                                title: '',
                                content: [
                                  [
                                    {
                                      tag: 'text',
                                      text: text
                                    }
                                  ]
                                ]
                              }
                            }
                          }
                        }, hook_id)
    end

    # 自定义机器人接口 发送卡片消息
    def custom_robot_send_card(title = '标题', theme = 'blue', elements = [], hook_id = '')
      custom_robot_send({
                          msg_type: 'interactive',
                          card: {
                            config: {
                              wide_screen_mode: true
                            },
                            header: {
                              title: {
                                tag: 'plain_text',
                                content: title
                              },
                              template: theme
                            },
                            elements: elements
                          }
                        }, hook_id)
    end
  end
end
