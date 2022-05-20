# frozen_string_literal: true

require 'slack-notifier'
require_relative '../config'

module Clients
  class Slack
    private_class_method :new

    def self.notify(text)
      new.notify(title: '本日の運動結果', color: 'good', text: text)
    end

    def self.warn(text)
      new.notify(title: '運動結果の取得に失敗しました', color: 'warning', text: text)
    end

    def notify(title:, color:, text:)
      attachments = [{ fallback: text, title: title, text: text, color: color }]
      client.post(attachments: attachments)
    end

    private

    def client
      @client ||= Client.new
    end

    class Client
      def post(attachments:)
        notifier.post(attachments: attachments)
      end

      def notifier
        @notifier ||= ::Slack::Notifier.new Settings.clients.slack.webhook_url do
          defaults channel: ::Settings.clients.slack.channel,
                   username: 'リングフィットアドベンチャー通知'
        end
      end
    end
  end
end
