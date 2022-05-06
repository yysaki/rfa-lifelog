# frozen_string_literal: true

require 'fog/aws'
require_relative '../config'

module Client
  class S3
    class UnexpectedError < ::StandardError; end

    PREFIX = 'rfa/'

    def create(file_name:, body:)
      directory = s3.directories.new(key: bucket_name)
      directory.files.create(key: "#{PREFIX}#{file_name}", body: body)
    rescue StandardError => e
      raise UnexpectedError, e.message
    end

    def list
      directory = s3.directories.get(bucket_name, prefix: PREFIX)
      directory.files
               .map { |file| file.key.gsub(PREFIX, '') }
               .select { |file_name| file_name.include? '.csv' }
    rescue StandardError => e
      raise UnexpectedError, e.message
    end

    private

    def s3
      @s3 ||= Fog::Storage.new(
        provider: 'AWS',
        region: 'ap-northeast-1',
        aws_access_key_id: Settings.clients.s3.aws_access_key_id,
        aws_secret_access_key: Settings.clients.s3.aws_secret_access_key
      )
    end

    def bucket_name
      @bucket_name ||= ENV.fetch('AWS_S3_BUCKET')
    end
  end
end
