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

    activities = active_activities(status_ids)
    activities.each do |a|
      s3.create(file_name: "#{a.status_id}.csv", body: a.to_csv)
    end

    activities.to_s
  end

  private

  def active_activities(status_ids)
    tweets = Clients::Twitter.list(count: Settings.usecase.count)
    tweets = tweets.reject { |tweet| status_ids.include? tweet.status_id.to_s } unless Settings.usecase.force
    tweets.map { |tweet| Clients::Vision.new.show(tweet) }.compact
  end
end
