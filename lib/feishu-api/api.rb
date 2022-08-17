# frozen_string_literal: true

module FeishuApi
  class << self
    API_HOST = 'https://open.feishu.cn/open-apis'

    API_TENANT_ACCESS_TOKEN = '/auth/v3/tenant_access_token/internal'
    API_APP_ACCESS_TOKEN = '/auth/v3/app_access_token/internal'
    API_SEND_MESSAGES = '/im/v1/messages'
    API_CUSTOM_BOT_SEND = '/bot/v2/hook'
    API_UPLOAD_IMAGE = '/im/v1/images'
    API_UPLOAD_FILES = '/im/v1/files'

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
      # p res
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

    # 上传图片
    def upload_image(path)
      HTTParty.post("#{API_HOST}#{API_UPLOAD_IMAGE}",
                    body: { image_type: 'message', image: File.new(path) },
                    headers: { 'Content-Type' => 'multipart/formdata', Authorization: "Bearer #{tenant_access_token}" })
    end

    # 下载图片
    def download_image(image_key)
      HTTParty.get("#{API_HOST}#{API_UPLOAD_IMAGE}/#{image_key}",
                   headers: { Authorization: "Bearer #{tenant_access_token}" })
    end

    # 上传文件
    def upload_file(path, file_type)
      HTTParty.post("#{API_HOST}#{API_UPLOAD_FILES}",
                    body: { file_type: file_type, file_name: File.basename(path), file: File.new(path) },
                    headers: { 'Content-Type' => 'multipart/formdata', Authorization: "Bearer #{tenant_access_token}" })
    end

    # 下载文件
    def download_file(file_key)
      HTTParty.get("#{API_HOST}#{API_UPLOAD_FILES}/#{file_key}",
                   headers: { Authorization: "Bearer #{tenant_access_token}" })
    end

    # 发文件消息到指定群聊
    def send_file_by_group(receive_id, file_key)
      send_message_by_group(receive_id, 'file', JSON.generate({ file_key: file_key }))
    end

    # 撤回消息
    def withdraw_message(message_id)
      HTTParty.delete("#{API_HOST}#{API_SEND_MESSAGES}/#{message_id}",
                      headers: { Authorization: "Bearer #{tenant_access_token}" })
    end

    # 查询消息已读信息
    def check_reader(message_id)
      HTTParty.get("#{API_HOST}#{API_SEND_MESSAGES}/#{message_id}/read_users?user_id_type=open_id",
                   headers: { Authorization: "Bearer #{tenant_access_token}" })
    end

    # 发图片消息到指定群聊
    def send_image_by_group(receive_id, image_key)
      send_message_by_group(receive_id, 'image', JSON.generate({ image_key: image_key }))
    end

    #  回复消息
    def reply_message(message_id)
      HTTParty.post("#{API_HOST}#{API_SEND_MESSAGES}/#{message_id}/reply",
                    body: { content: '{"text":" test content"}', msg_type: 'text' },
                    headers: { Authorization: "Bearer #{tenant_access_token}" })
    end

    # 获取会话（历史）消息
    def get_chat_messages(container_id)
      HTTParty.get("#{API_HOST}#{API_SEND_MESSAGES}?container_id_type=chat&container_id=#{container_id}", headers: { Authorization: "Bearer #{tenant_access_token}" })
    end

    # 获取指定消息的内容
    def get_message_content(message_id)
      HTTParty.get("#{API_HOST}#{API_SEND_MESSAGES}/#{message_id}", headers: { Authorization: "Bearer #{tenant_access_token}" })
    end

    # 发送应用内加急消息 （需要相关权限）
    def send_urgent_app_message(message_id, user_id)
      HTTParty.patch("#{API_HOST}#{API_SEND_MESSAGES}/#{message_id}/urgent_app?user_id_type=user_id",
                     headers: { Authorization: "Bearer #{tenant_access_token}" },
                     body: { user_id_list: [user_id] })
    end

    # # 添加消息表情回复
    # def add_message_reactions(message_id,emoji_type)
    #   HTTParty.post("#{API_HOST}#{API_SEND_MESSAGES}/#{message_id}/reactions",
    #     headers:{Authorization: "Bearer #{tenant_access_token}"},
    #     body: {
    #       "reaction_type": 'emoji',
    #       "reaction_type": {
    #           "emoji_type": emoji_type
    #       }
    #   })
    # end

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
