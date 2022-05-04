# frozen_string_literal: true

require 'twitter'

module Client
  class Twitter
    class Error < ::StandardError; end
    class UnauthorizedError < Error; end
    class UnexpectedError < Error; end

    class Tweet
      attr_reader :status_id, :created_at, :photo_urls

      def initialize(status_id:, created_at:, photo_urls:)
        @status_id = status_id
        @created_at = created_at
        @photo_urls = photo_urls
      end

      def self.build(tweet)
        Tweet.new(
          status_id: tweet.id,
          created_at: tweet.created_at.iso8601,
          photo_urls: photo_urls_from(tweet)
        )
      end

      def self.photo_urls_from(tweet)
        tweet.media
             .select { |m| m.is_a? ::Twitter::Media::Photo }
             .map { |m| m.media_uri_https.to_s }
      end
    end

    def list(count: 20, user_id: 'yysaki', hash_tag: '#RingFitAdventure')
      client.user_timeline(user_id, count:)
            .select { |tweet| tweet.text.include? hash_tag }
            .map { |tweet| Tweet.build(tweet) }
    rescue ::Twitter::Error::Unauthorized => e
      raise UnauthorizedError, e.message
    rescue StandardError => e
      raise UnexpectedError, e.message
    end

    private

    def client
      @client ||= ::Twitter::REST::Client.new(
        consumer_key: ENV.fetch('TWITTER_CONSUMER_KEY', nil),
        consumer_secret: ENV.fetch('TWITTER_CONSUMER_SECRET', nil),
        bearer_token: ENV.fetch('TWITTER_BEARER_TOKEN', nil)
      )
    end
  end
end
