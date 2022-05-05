# frozen_string_literal: true

require 'twitter'

module Client
  class Twitter
    class Error < ::StandardError; end
    class UnauthorizedError < Error; end
    class UnexpectedError < Error; end

    Status = Struct.new(:status_id, :tweeted_at, :photo_urls)

    def list(count: 20, user_id: 'yysaki', hash_tag: '#RingFitAdventure')
      tweets = client.user_timeline(user_id, count:)
      statusify(tweets, hash_tag)
    rescue ::Twitter::Error::Unauthorized => e
      raise UnauthorizedError, e.message
    rescue StandardError => e
      raise UnexpectedError, e.message
    end

    private

    def statusify(tweets, hash_tag)
      tweets
        .select { |t| t.text.include? hash_tag }
        .map { |t| Status.new(t.id, t.created_at.iso8601, photo_urls_from(t)) }
    end

    def photo_urls_from(tweet)
      tweet.media
           .select { |m| m.is_a? ::Twitter::Media::Photo }
           .map { |m| m.media_uri_https.to_s }
    end

    def client
      @client ||= ::Twitter::REST::Client.new(
        consumer_key: ENV.fetch('TWITTER_CONSUMER_KEY', nil),
        consumer_secret: ENV.fetch('TWITTER_CONSUMER_SECRET', nil),
        bearer_token: ENV.fetch('TWITTER_BEARER_TOKEN', nil)
      )
    end
  end
end
