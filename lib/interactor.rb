# frozen_string_literal: true

require_relative 'config'
require_relative 'clients'

class Interactor
  private_class_method :new

  def self.call
    new.call
  end

  def call
    status_ids = s3.list.map { |file_name| file_name.gsub('.csv', '') }

    active_activities(status_ids).each do |a|
      s3.create(file_name: "#{a.status_id}.csv", body: a.to_csv)
      slack.notify(text(a))
    end
  rescue StandardError => e
    slack.warn(e.message)
    raise
  end

  private

  def active_activities(status_ids)
    tweets = twitter.list(count: Settings.usecase.count)
    tweets = tweets.reject { |tweet| status_ids.include? tweet.status_id.to_s } unless Settings.usecase.force
    tweets.map { |tweet| vision.show(tweet) }.compact
  end

  def text(activity)
    <<~TEXT
      ・url: https://twitter.com/#{Clients::Twitter::USER_ID}/status/#{activity.status_id}
      ・合計活動時間: #{activity.activity_time}
      ・合計消費カロリー: #{activity.consumption_calory}kcal
      ・合計走行距離: #{activity.running_distance}km
    TEXT
  end

  def s3
    Clients::S3
  end

  def slack
    Clients::Slack
  end

  def vision
    Clients::Vision
  end

  def twitter
    Clients::Twitter
  end
end
