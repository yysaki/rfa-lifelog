# frozen_string_literal: true

require_relative 'clients'

def handler(event:, context:) # rubocop:disable Lint/UnusedMethodArgument
  count = event[:count] || 20
  force = event[:force] || false
  s3 = Client::S3.new
  status_ids = s3.list.map { |file_name| file_name.gsub('.csv', '') }

  activities = active_activities(status_ids, count, force)
  activities.each do |a|
    s3.create(file_name: "#{a.status_id}.csv", body: a.to_csv)
  end

  activities.to_s
end

def active_activities(status_ids, count, force)
  twitter = Client::Twitter.new
  vision = Client::Vision.new

  tweets = twitter.list(count: count)
  tweets = tweets.reject { |tweet| status_ids.include? tweet.status_id.to_s } unless force
  tweets.map { |tweet| vision.show(tweet) }
        .compact
end

pp handler(event: { count: ARGV.shift, force: ARGV.shift }, context: {}) if __FILE__ == $PROGRAM_NAME
