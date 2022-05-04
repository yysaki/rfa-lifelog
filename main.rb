# frozen_string_literal: true

require_relative './clients/twitter'
require_relative './clients/vision'

def main(count: 20)
  tweets = Client::Twitter.new.list(count:)
  vision = Client::Vision.new
  activities = tweets.map { |tweet| vision.show(tweet) }
  pp activities
end

main(count: 20)
