# frozen_string_literal: true

require_relative 'config'
require_relative 'clients'

class Interactor
  private_class_method :new

  def self.call
    new.call
  end

  def call
    status_ids = Clients::S3.list.map { |file_name| file_name.gsub('.csv', '') }

    active_activities(status_ids).each do |a|
      Clients::S3.create(file_name: "#{a.status_id}.csv", body: a.to_csv)
      Clients::Slack.notify(text(a))
      puts text(a)
    end
  rescue StandardError => e
    Clients::Slack.warn(e.message)
    raise
  end

  private

  def active_activities(status_ids)
    tweets = Clients::Twitter.list(count: Settings.usecase.count)
    tweets = tweets.reject { |tweet| status_ids.include? tweet.status_id.to_s } unless Settings.usecase.force
    tweets.map { |tweet| Clients::Vision.show(tweet) }.compact
  end

  def text(activity)
    <<~TEXT
      ・URL: https://twitter.com/#{Clients::Twitter::USER_ID}/status/#{activity.status_id}
      ・合計活動時間: #{activity.activity_time}
      ・合計消費カロリー: #{activity.consumption_calory}
      ・合計走行距離:
    TEXT
  end
end
