require 'twitter'

module Twitter
  class SearchClient
    USER_ID = 'yysaki'
    HASH_TAG = '#RingFitAdventure'

    def search(count: 20)
      client.user_timeline(USER_ID, count:)
        .select { |tweet| tweet.text.include? HASH_TAG }
    end

    private

    def client
      @client ||= Twitter::REST::Client.new(
        consumer_key:    ENV['TWITTER_CONSUMER_KEY'],
        consumer_secret: ENV['TWITTER_CONSUMER_SECRET'],
        bearer_token:    ENV['TWITTER_BEARER_TOKEN']
      )
    end
  end
end

# Twitter::SearchClient.new.search(count: 200).each do |tweet|
#   puts "id: #{tweet.id}"
#   puts "created_at: #{tweet.created_at}"
#   puts "text: #{tweet.text}"
#   puts "media uris: #{tweet.media.map(&:media_uri_https).map(&:to_s)}"
# end
