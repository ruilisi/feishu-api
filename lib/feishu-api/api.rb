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
    API_CHATS = '/im/v1/chats'
    API_RESERVES = '/vc/v1/reserves'
    API_MEETINGS = '/vc/v1/meetings'

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

    def post_with_token(url, data, headers = {}, timeout = 30)
      HTTParty.post(api(url),
                    body: data,
                    headers: { Authorization: "Bearer #{tenant_access_token}" }.merge(headers),
                    timeout: timeout)
    end

    def post_with_user_token(url, user_access_token, data, headers = {}, timeout = 30)
      HTTParty.post(api(url),
                    body: data,
                    headers: { Authorization: "Bearer #{user_access_token}" }.merge(headers),
                    timeout: timeout)
    end

    def get_with_token(url, data = {}, headers = {}, timeout = 30)
      HTTParty.get(api(url),
                   body: data,
                   headers: { Authorization: "Bearer #{tenant_access_token}" }.merge(headers),
                   timeout: timeout)
    end

    def get_with_user_token(url, user_access_token, data = {}, headers = {}, timeout = 30)
      HTTParty.get(api(url),
                   body: data,
                   headers: { Authorization: "Bearer #{user_access_token}" }.merge(headers),
                   timeout: timeout)
    end

    def put_with_token(url, data = {}, headers = {}, timeout = 30)
      HTTParty.put(api(url),
                   body: data,
                   headers: { Authorization: "Bearer #{tenant_access_token}" }.merge(headers),
                   timeout: timeout)
    end

    def put_with_user_token(url, user_access_token, data = {}, headers = {}, timeout = 30)
      HTTParty.put(api(url),
                   body: data,
                   headers: { Authorization: "Bearer #{user_access_token}" }.merge(headers),
                   timeout: timeout)
    end

    def delete_with_token(url, data = {}, headers = {}, timeout = 30)
      HTTParty.delete(api(url),
                      body: data,
                      headers: { Authorization: "Bearer #{tenant_access_token}" }.merge(headers),
                      timeout: timeout)
    end

    def delete_with_user_token(url, user_access_token, data = {}, headers = {}, timeout = 30)
      HTTParty.delete(api(url),
                      body: data,
                      headers: { Authorization: "Bearer #{user_access_token}" }.merge(headers),
                      timeout: timeout)
    end

    def patch_with_token(url, data = {}, headers = {}, timeout = 30)
      HTTParty.patch(api(url),
                     body: data,
                     headers: { Authorization: "Bearer #{tenant_access_token}" }.merge(headers),
                     timeout: timeout)
    end

    def patch_with_user_token(url, user_access_token, data = {}, headers = {}, timeout = 30)
      HTTParty.patch(api(url),
                     body: data,
                     headers: { Authorization: "Bearer #{user_access_token}" }.merge(headers),
                     timeout: timeout)
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

    # ????????????
    def send_message(receive_type, receive_id, msg_type, content)
      res = post_with_token("#{API_SEND_MESSAGES}?receive_id_type=#{receive_type}",
                            { receive_id: receive_id, msg_type: msg_type, content: content })
      # p res
      return nil if res.code != 200

      JSON.parse(res.body)
    end

    # ????????????????????????
    def send_message_by_group(receive_id, msg_type, content)
      send_message('chat_id', receive_id, msg_type, content)
    end

    # ??????????????????????????????
    def send_text_by_group(receive_id, text)
      send_message_by_group(receive_id, 'text', JSON.generate({ text: text }))
    end

    # ????????????
    def upload_image(path)
      post_with_token(API_UPLOAD_IMAGE.to_s, { image_type: 'message', image: File.new(path) },
                      { 'Content-Type' => 'multipart/formdata', 'Accept' => 'application/json' })
    end

    # ????????????
    def download_image(image_key)
      get_with_token("#{API_UPLOAD_IMAGE}/#{image_key}")
    end

    # ????????????
    def upload_file(path, file_type)
      post_with_token(API_UPLOAD_FILES.to_s,
                      { file_type: file_type, file_name: File.basename(path), file: File.new(path) },
                      { 'Content-Type' => 'multipart/formdata' })
    end

    # ????????????
    def download_file(file_key)
      HTTParty.get("#{API_HOST}#{API_UPLOAD_FILES}/#{file_key}",
                   headers: { Authorization: "Bearer #{tenant_access_token}" })
    end

    # ??????????????????????????????
    def send_file_by_group(receive_id, file_key)
      send_message_by_group(receive_id, 'file', JSON.generate({ file_key: file_key }))
    end

    # ????????????
    def withdraw_message(message_id)
      delete_with_token("#{API_SEND_MESSAGES}/#{message_id}")
    end

    # ????????????????????????
    def check_reader(message_id)
      get_with_token("#{API_SEND_MESSAGES}/#{message_id}/read_users?user_id_type=open_id")
    end

    # ??????????????????????????????
    def send_image_by_group(receive_id, image_key)
      send_message_by_group(receive_id, 'image', JSON.generate({ image_key: image_key }))
    end

    #  ????????????
    def reply_message(message_id)
      post_with_token("#{API_SEND_MESSAGES}/#{message_id}/reply",
                      { content: '{"text":" test content"}', msg_type: 'text' })
    end

    # ??????????????????????????????
    def get_chat_messages(container_id)
      get_with_token("#{API_SEND_MESSAGES}?container_id_type=chat&container_id=#{container_id}")
    end

    # ???????????????????????????
    def get_message_content(message_id)
      get_with_token("#{API_SEND_MESSAGES}/#{message_id}")
    end

    # ??????????????????????????? ????????????????????????
    def send_urgent_app_message(message_id, user_id)
      patch_with_token("#{API_SEND_MESSAGES}/#{message_id}/urgent_app?user_id_type=user_id",
                       { user_id_list: [user_id] })
    end

    # ????????????????????????
    def add_message_reactions(message_id, emoji_type)
      post_with_token("#{API_SEND_MESSAGES}/#{message_id}/reactions",
                      {
                        reaction_type: {
                          emoji_type: emoji_type.to_s
                        }
                      }.to_json, { 'Content-Type' => 'application/json' })
    end

    # ????????????????????????
    def get_message_reactions(message_id)
      get_with_token("#{API_SEND_MESSAGES}/#{message_id}/reactions")
    end

    # ????????????????????????
    def delete_message_reactions(message_id)
      delete_with_token("#{API_SEND_MESSAGES}/#{message_id}/reactions")
    end

    # ??????????????????????????????????????????
    def bot_chat_list
      get_with_token(API_CHATS.to_s)
    end

    # ?????????????????????????????????????????????
    def search_chat_list(query)
      get_with_token("#{API_CHATS}/search?query=#{query}")
    end

    # ?????????????????? chat_id:oc_31e9100a2673814ecba937f0772b8ebc
    # ???????????????????????????
    def get_member_permission(chat_id)
      get_with_token("#{API_CHATS}/#{chat_id}/moderation")
    end

    # ???????????????????????????
    def update_member_permission(chat_id)
      put_with_token("#{API_CHATS}/#{chat_id}/moderation")
    end

    # ???????????????
    def update_group_top_notice(chat_id, message_id)
      post_with_token("#{API_CHATS}/#{chat_id}/top_notice/put_top_notice",
                      {
                        chat_top_notice: [
                          {
                            action_type: '1',
                            message_id: message_id.to_s
                          }
                        ]
                      }.to_json, { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
    end

    # ???????????????
    def delete_group_top_notice(chat_id)
      delete_with_token("#{API_CHATS}/#{chat_id}/top_notice/delete_top_notice")
    end

    # ?????????
    def create_group(name)
      post_with_token(API_CHATS.to_s,
                      { name: name.to_s })
    end

    # ???????????????
    def get_group_info(chat_id)
      get_with_token("#{API_CHATS}/#{chat_id}")
    end

    # ???????????????
    def update_group_info(chat_id, description)
      put_with_token("#{API_CHATS}/#{chat_id}", { description: description.to_s })
    end

    # ?????????
    def dissolve_group(chat_id)
      delete_with_token("#{API_CHATS}/#{chat_id}")
    end

    # ?????????????????????????????????
    def add_group_member(chat_id, id_list)
      post_with_token("#{API_CHATS}/#{chat_id}/members",
                      { id_list: id_list }.to_json, { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
    end

    # ?????????????????????????????????
    def delete_group_member(chat_id, id_list)
      delete_with_token("#{API_CHATS}/#{chat_id}/members",
                        { id_list: id_list }.to_json, { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
    end

    # ????????????????????????????????????
    # ??????????????????????????????
    def join_group(chat_id)
      patch_with_token("#{API_CHATS}/#{chat_id}/members/me_join")
    end

    # ???????????????????????????????????????
    def member_is_in_chat(chat_id)
      get_with_token("#{API_CHATS}/#{chat_id}/members/is_in_chat")
    end

    # ??????????????????
    def add_group_managers(chat_id, manager_ids)
      post_with_token("#{API_CHATS}/#{chat_id}/managers/add_managers",
                      { manager_ids: manager_ids }.to_json, { 'Content-Type' => 'application/json' })
    end

    # ??????????????????
    def delete_group_managers(chat_id, manager_ids)
      post_with_token("#{API_CHATS}/#{chat_id}/managers/delete_managers",
                      { manager_ids: manager_ids }.to_json, { 'Content-Type' => 'application/json' })
    end

    # ?????????????????????
    def get_group_members(chat_id)
      get_with_token("#{API_CHATS}/#{chat_id}/members")
    end

    # ?????????????????????
    def get_group_announcement(chat_id)
      get_with_token("#{API_CHATS}/#{chat_id}/announcement")
    end

    # ?????????????????????
    # rubocop:disable all
    def update_group_announcement(chat_id)
      patch_with_token("#{API_CHATS}/#{chat_id}/announcement",
        {
          "revision": "0",
          "requests": [
            "{\"requestType\":\"UpdateTitleRequestType\",\"updateTitleRequest\":{\"payload\":\"{\\\"elements\\\":[{\\\"type\\\":\\\"textRun\\\",\\\"textRun\\\":{\\\"text\\\":\\\"Updated Document Title\\\",\\\"style\\\":{}}}],\\\"style\\\":{}}\"}}"
          ]
        }.to_json, { 'Content-Type' => 'application/json'})
    end
    # rubocop:enable all

    # ????????????????????????, ????????????????????????
    def send_message_by_email(receive_id, msg_type, content)
      send_message('email', receive_id, msg_type, content)
    end

    # ???????????????????????? ????????????
    def custom_robot_send(data, hook_id)
      post("#{API_CUSTOM_BOT_SEND}/#{hook_id}", data)
      return nil if res.code != 200

      JSON.parse(res.body)
    end

    # ????????????
    def reserve_meeting(token, end_time, check_list, topic)
      post_with_user_token("#{API_RESERVES}/apply", token, {
        end_time: Time.strptime(end_time, '%Y-%m-%d %H:%M:%S').to_i,
        meeting_settings: {
          topic: topic,
          action_permissions: [
            {
              permission: 1,
              permission_checkers: [
                {
                  check_field: 1,
                  check_mode: 1,
                  check_list: check_list
                }
              ]
            }
          ],
          meeting_initial_type: 1,
          call_setting: {
            callee: {
              id: check_list[0],
              user_type: 1,
              pstn_sip_info: {
                nickname: 'dodo',
                main_address: '+86-02187654321'
              }
            }
          },
          auto_record: true
        }
      }.to_json, { 'Content-Type' => 'application/json' })
    end

    # ????????????
    def update_reserve(token, reserve_id, topic, check_list, end_time)
      put_with_user_token("#{API_RESERVES}/#{reserve_id}", token,
                          {
                            end_time: Time.strptime(end_time, '%Y-%m-%d %H:%M:%S').to_i,
                            meeting_settings: {
                              topic: topic,
                              action_permissions: [
                                {
                                  permission: 1,
                                  permission_checkers: [
                                    {
                                      check_field: 1,
                                      check_mode: 1,
                                      check_list: check_list
                                    }
                                  ]
                                }
                              ],
                              meeting_initial_type: 1,
                              call_setting: {
                                callee: {
                                  id: check_list[0],
                                  user_type: 1,
                                  pstn_sip_info: {
                                    nickname: 'dodo',
                                    main_address: '+86-02187654321'
                                  }
                                }
                              },
                              auto_record: true
                            }
                          }.to_json, { 'Content-Type' => 'application/json' })
    end

    # ????????????
    def delete_reserve(token, reserve_id)
      delete_with_user_token("#{API_RESERVES}/#{reserve_id}", token)
    end

    # ????????????
    def get_reserve_info(token, reserve_id)
      get_with_user_token("#{API_RESERVES}/#{reserve_id}", token)
    end

    # ??????????????????
    def get_active_meeting(token, reserve_id)
      get_with_user_token("#{API_RESERVES}/#{reserve_id}/get_active_meeting", token)
    end

    # ??????????????????
    def get_meeting_info(meeting_id)
      get_with_token("#{API_MEETINGS}/#{meeting_id}")
    end

    # ??????????????????????????????????????????
    def get_list_by_no(meeting_number, start_time, end_time)
      end_time_unix = Time.strptime(end_time, '%Y-%m-%d %H:%M:%S').to_i
      start_time_unix = Time.strptime(start_time, '%Y-%m-%d %H:%M:%S').to_i
      get_with_token("#{API_MEETINGS}/list_by_no?end_time=#{end_time_unix}&start_time=#{start_time_unix}&meeting_no=#{meeting_number}")
    end

    # ???????????????????????? ??????????????????
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

    # ???????????????????????? ??????????????????
    def custom_robot_send_card(title = '??????', theme = 'blue', elements = [], hook_id = '')
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
