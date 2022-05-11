# frozen_string_literal: true

require 'twitter'
require_relative '../config'

module Clients
  class Twitter
    Status = Struct.new(:status_id, :tweeted_at, :photo_urls)

    HASH_TAG = '#RingFitAdventure'
    USER_ID = 'yysaki'

    def self.list(count:)
      new.list(count: count)
    end

    def list(count:)
      tweets = client.user_timeline(USER_ID, count: count)
      statusify(tweets)
    end

    private

    def statusify(tweets)
      tweets
        .select { |t| t.text.include? HASH_TAG }
        .map { |t| Status.new(t.id, t.created_at.iso8601, photo_urls_from(t)) }
    end

    def photo_urls_from(tweet)
      tweet.media
           .select { |m| m.is_a? ::Twitter::Media::Photo }
           .map { |m| m.media_uri_https.to_s }
    end

    def client
      @client ||= ::Twitter::REST::Client.new(
        consumer_key: Settings.clients.twitter.consumer_key,
        consumer_secret: Settings.clients.twitter.consumer_secret,
        bearer_token: Settings.clients.twitter.bearer_token
      )
    end
  end
end
