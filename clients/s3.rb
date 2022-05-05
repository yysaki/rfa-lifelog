# frozen_string_literal: true

require 'fog/aws'

module Client
  class S3
    PREFIX = 'rfa/'

    def create(file_name:, body:)
      directory = s3.directories.new(key: bucket_name)
      directory.files.create(key: "#{PREFIX}#{file_name}", body:)
    end

    def list
      directory = s3.directories.get(bucket_name, prefix: PREFIX)
      directory.files
        .map { |file| file.key.gsub(PREFIX, '') }
        .select { |file_name| file_name.include? '.csv' }
    end

    private

    def s3
      @s3 ||= Fog::Storage.new(
        provider: 'AWS',
        region: 'ap-northeast-1',
        aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
        aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY')
      )
    end

    def bucket_name
      @bucket_name ||= ENV.fetch('AWS_S3_BUCKET')
    end
  end
end
