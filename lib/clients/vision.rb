# frozen_string_literal: true

require 'csv'
require 'google/cloud/vision'
require_relative '../config'

module Clients
  class Vision
    Activity = Struct.new(:status_id, :tweeted_at, :activity_time, :consumption_calory) do
      def to_csv
        attributes = %i[status_id tweeted_at activity_time consumption_calory].freeze
        CSV.generate do |csv|
          csv << attributes.map(&:to_s)
          csv << attributes.map { |attr| send attr }
        end
      end
    end

    def self.show(tweet)
      new.show(tweet)
    end

    def initialize
      create_credentials_file unless File.exist?(Settings.clients.vision.google_application_credentials_path)
    end

    def show(tweet)
      image_annotator = Google::Cloud::Vision.image_annotator
      descriptions = tweet.photo_urls.map do |url|
        response = image_annotator.text_detection(image: url)
        response.responses.first.text_annotations.first.description
      end

      activitify(tweet, descriptions)
    end

    private

    def activitify(tweet, descriptions)
      description = descriptions.select { |desc| desc.include? '合計活動時間' }.first
      return nil if description.nil?

      consumption_calory = description.scan(/(\d+\.\d+)kcal/).first&.first
      activity_time = description.scan(/((\d+)時間)?(\d+)分(\d+)秒/).first&.compact&.join(':')

      Activity.new(tweet.status_id, tweet.tweeted_at, activity_time, consumption_calory)
    end

    def create_credentials_file
      File.write(Settings.clients.vision.google_application_credentials_path,
                 Settings.clients.vision.google_application_credentials_json)
    end
  end
end
