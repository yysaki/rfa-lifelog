# frozen_string_literal: true

require_relative 'clients/s3'
require_relative 'clients/twitter'
require_relative 'clients/vision'

def main(count:)
  s3 = Client::S3.new
  status_ids = s3.list.map { |file_name| file_name.gsub('.csv', '') }

  activities = active_activities(status_ids:, count:)
  activities.each do |a|
    s3.create(file_name: "#{a.status_id}.csv", body: a.to_csv)
  end

  pp activities
end

def active_activities(status_ids:, count:)
  twitter = Client::Twitter.new
  vision = Client::Vision.new

  twitter.list(count:)
         .reject { |tweet| status_ids.include? tweet.status_id }
         .map { |tweet| vision.show(tweet) }
         .compact
end

main(count: ARGV.shift || 20)
