# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/clients/s3'
require 'fog/aws/storage'
require 'fog/aws/models/storage/directories'

RSpec.describe Clients::S3 do
  before do
    Fog.mock!
    s3.directories.create(key: bucket_name) unless s3.directories.get(bucket_name)
  end

  after { Fog.unmock! }

  let(:bucket_name) { 'bucket' }
  let(:s3) do
    Fog::Storage.new(
      provider: 'AWS',
      region: 'ap-northeast-1',
      aws_access_key_id: 'key',
      aws_secret_access_key: 'secret'
    )
  end

  describe '.create' do
    subject(:create) { described_class.create(file_name: file_name, body: body) }

    let(:file_name) { '1403666694648733702.csv' }
    let(:body) { 'dummy' }
    let(:files) { s3.directories.get(bucket_name, prefix: 'rfa/').files }

    it 'returns one emelent in array' do
      create
      expect(files).to be_one
    end

    it 'returns expected file_name' do
      create
      expect(files.first.key).to eq("rfa/#{file_name}")
    end

    it 'returns expected body' do
      create
      expect(files.first.body).to eq(body)
    end
  end

  describe '.list' do
    subject { described_class.list }

    let(:file_names) { %w[1403666694648733702.csv 1408631382734082052.csv 1411635422938034179.csv] }
    let(:files) { s3.directories.get(bucket_name).files }

    before { file_names.each { |file_name| files.create(key: "rfa/#{file_name}", body: 'dummy') } }

    it { is_expected.to contain_exactly(*file_names) }
  end
end
