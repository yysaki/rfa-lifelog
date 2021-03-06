# frozen_string_literal: true

require 'csv'
require 'google/cloud/vision'
require_relative '../config'

module Clients
  class Vision
    private_class_method :new

    ACTIVITY_ATTRIBUTES = %i[status_id tweeted_at activity_time consumption_calory running_distance].freeze
    Activity = Struct.new(*ACTIVITY_ATTRIBUTES) do
      def to_csv
        CSV.generate do |csv|
          csv << ACTIVITY_ATTRIBUTES.map(&:to_s)
          csv << ACTIVITY_ATTRIBUTES.map { |attr| send attr }
        end
      end

      def to_s
        <<~TEXT
          ・url: https://twitter.com/#{Clients::Twitter::USER_ID}/status/#{status_id}
          ・合計活動時間: #{activity_time}
          ・合計消費カロリー: #{consumption_calory}kcal
          ・合計走行距離: #{running_distance}km
        TEXT
      end
    end

    def self.show(status)
      new.show(status)
    end

    def show(status)
      description = status.photo_urls
                          .map { |url| client.text_detection(url: url) }
                          .select { |desc| desc.include? '合計活動時間' }
                          .first
      return nil if description.nil?

      activitify(status, description)
    end

    private

    def activitify(status, description)
      consumption_calory = description.scan(/(\d+\.\d+)kcal/).first&.first
      activity_time = description.scan(/((\d+)時間)?(\d+)分(\d+)秒/).first&.compact&.join(':')
      running_distance = description.scan(/(\d+\.\d+)km/).first&.first

      Activity.new(status.status_id, status.tweeted_at, activity_time, consumption_calory, running_distance)
    end

    def client
      @client ||= Client.new
    end

    class Client
      def initialize
        create_credentials_file unless File.exist?(Settings.clients.vision.google_application_credentials_path)
      end

      def text_detection(url:)
        image_annotator = Google::Cloud::Vision.image_annotator

        response = image_annotator.text_detection(image: url)
        response.responses.first.text_annotations.first.description
      end

      private

      def create_credentials_file
        File.write(Settings.clients.vision.google_application_credentials_path,
                   Settings.clients.vision.google_application_credentials_json)
      end
    end
  end
end
