# frozen_string_literal: true

require 'fog/aws'
require_relative '../config'

module Clients
  class S3
    PREFIX = 'rfa/'

    def self.create(file_name:, body:)
      new.create(file_name: file_name, body: body)
    end

    def self.list
      new.list
    end

    def create(file_name:, body:)
      directory = s3.directories.new(key: bucket_name)
      directory.files.create(key: "#{PREFIX}#{file_name}", body: body)
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
        aws_access_key_id: Settings.clients.s3.aws_access_key_id,
        aws_secret_access_key: Settings.clients.s3.aws_secret_access_key
      )
    end

    def bucket_name
      @bucket_name ||= Settings.clients.s3.aws_bucket_name
    end
  end
end
