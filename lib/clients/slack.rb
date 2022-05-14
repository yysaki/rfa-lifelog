# frozen_string_literal: true

require 'slack-notifier'

module Clients
  class Slack
    private_class_method :new

    USERNAME = 'リングフィットアドベンチャー通知'

    def self.notify(text)
      new.notify(title: '本日の運動結果', color: 'good', text: text)
    end

    def self.warn(text)
      new.notify(title: '運動結果の取得に失敗しました', color: 'warning', text: text)
    end

    def notify(title:, color:, text:)
      attachments = [{ fallback: text, title: title, text: text, color: color }]
      notifier.post(attachments: attachments)
    end

    private

    def notifier
      @notifier ||= ::Slack::Notifier.new Settings.clients.slack.webhook_url do
        defaults channel: Settings.clients.slack.channel,
                 username: USERNAME
      end
    end
  end
end
