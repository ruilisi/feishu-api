# frozen_string_literal: true

module FeishuApi
  class Config
    class << self
      attr_accessor :app_id, :app_secret, :encrypt_key

      def configure
        yield self
      end
    end
  end
end
