# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/clients/twitter'

RSpec.describe Clients::Twitter do
  describe '.list' do
    subject(:list) { described_class.list(count: 20) }

    before do
      client = instance_double(Twitter::REST::Client)
      allow(Twitter::REST::Client).to receive(:new).and_return(client)
      allow(client).to receive(:user_timeline).and_return([tweet])
    end

    context 'when target tweet does not exist in timeline' do
      let(:tweet) { Twitter::Tweet.new(id: 12_345_678_902, text: 'つぶやき') }

      it 'returns empty array' do
        expect(list).to be_empty
      end
    end

    context 'when target tweet exists in timeline' do
      let(:id) { 12_345_678_901 }
      let(:created_at) { 'Mon May 9 12:34:56 +0000 2022' }
      let(:photo_url) {  'https://example.com/media/FSNMwAtUUAAju-x?format=jpg&name=large' }
      let(:tweet) do
        media = { id: 1, type: 'photo', media_url_https: photo_url }
        Twitter::Tweet.new(id: id, text: '#RingFitAdventure', created_at: created_at, entities: { media: [media] })
      end
      let(:expected) do
        {
          status_id: id,
          tweeted_at: Time.parse(created_at).utc.iso8601.to_s,
          photo_urls: [photo_url]
        }
      end

      it 'returns one element in array' do
        expect(list).to be_one
      end

      it 'returns Status instance' do
        expect(list.first).to be_a described_class::Status
      end

      it 'returns expeted value' do
        expect(list.first.to_h).to eq expected
      end
    end
  end
end
