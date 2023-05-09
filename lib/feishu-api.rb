# frozen_string_literal: true

require 'feishu-api/engine'
require 'feishu-api/config'
require 'feishu-api/api'

require 'httparty'
require 'openssl'
require 'base64'

module FeishuApi
  # Your code goes here...
  class << self
    def configure(&block)
      Config.configure(&block)
    end
  end
end
