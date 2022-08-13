# frozen_string_literal: true

module FeishuApi
  class Engine < ::Rails::Engine
    isolate_namespace FeishuApi

    initializer('feishu-api', after: :load_config_initializers) do |_app|
      Rails.application.routes.prepend do
        mount FeishuApi::Engine, at: '/feishu-api'
      end
    end
  end
end
