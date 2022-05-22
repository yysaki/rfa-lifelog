# frozen_string_literal: true

require_relative 'config'
require_relative 'clients'

class Interactor
  private_class_method :new

  def self.call
    new.call
  end

  attr_reader :s3, :slack, :vision, :twitter

  def initialize
    @s3 = Clients::S3
    @slack = Clients::Slack
    @vision = Clients::Vision
    @twitter = Clients::Twitter
  end

  def call
    activities.each do |activity|
      s3.create(file_name: "#{activity.status_id}.csv", body: activity.to_csv)
      slack.notify(activity.to_s)
    end
  rescue StandardError => e
    slack.warn(e.message)
    raise
  end

  private

  def activities
    ignored_ids = status_ids

    twitter.list(count: Settings.usecase.count)
           .select { |tweet| Settings.usecase.force || !ignored_ids.include?(tweet.status_id.to_s) }
           .map { |tweet| vision.show(tweet) }
           .compact
  end

  def status_ids
    s3.list.map { |file_name| file_name.gsub('.csv', '') }
  end
end
