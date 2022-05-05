# frozen_string_literal: true

require 'csv'
require 'google/cloud/vision'

module Client
  class Vision
    class UnexpectedError < ::StandardError; end

    class Activity
      ATTRIBUTES = %i[status_id created_at activity_time consumption_calory].freeze
      attr_reader(*ATTRIBUTES)

      def initialize(status_id:, created_at:, activity_time:, consumption_calory:)
        @status_id = status_id
        @created_at = created_at
        @activity_time = activity_time
        @consumption_calory = consumption_calory
      end

      def to_csv
        CSV.generate do |csv|
          csv << ATTRIBUTES.map(&:to_s)
          csv << ATTRIBUTES.map { |attr| send attr }
        end
      end

      def self.build(tweet:, descriptions:)
        description = descriptions.select { |desc| desc.include? '合計活動時間' }.first
        return if description.nil?

        consumption_calory = description.scan(/(\d+\.\d+)kcal/).first&.first
        activity_time = description.scan(/((\d+)時間)?(\d+)分(\d+)秒/).first&.compact&.join(':')

        Activity.new(status_id: tweet.status_id, created_at: tweet.created_at, activity_time:, consumption_calory:)
      end
    end

    def show(tweet)
      image_annotator = Google::Cloud::Vision.image_annotator
      descriptions = tweet.photo_urls.map do |url|
        response = image_annotator.text_detection(image: url)
        response.responses.first.text_annotations.first.description
      end

      Activity.build(tweet:, descriptions:)
    rescue StandardError => e
      raise UnexpectedError, e.message
    end
  end
end
