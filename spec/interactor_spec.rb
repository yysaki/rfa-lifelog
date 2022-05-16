# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/interactor'

RSpec.describe Interactor do
  describe '.call' do
    subject(:call) { described_class.call }

    context 'with raise error' do
      let(:message) { 'error happened' }

      before do
        allow(Clients::S3).to receive(:list).and_raise(message)
        allow(Clients::Slack).to receive(:warn)
      end

      it 'raise error' do
        expect { call }.to raise_error(message)
      end

      it 'returns with Clients::Slack.warn called' do
        call rescue false # rubocop:disable Style/RescueModifier
        expect(Clients::Slack).to have_received(:warn).with(message)
      end
    end

    context 'with successful' do
      let(:persisted_status) do
        Clients::Twitter::Status.new(
          1_523_145_488_362_393_601,
          '2022-05-08T03:39:17Z',
          'https://example.com/media/FSNMwAuVIAIj89B?format=jpg&name=large'
        )
      end
      let(:status) do
        Clients::Twitter::Status.new(
          1_403_666_694_648_733_702,
          '2022-05-09T01:23:45Z',
          'https://example.com/media/FSNMwAtUUAAju-x?format=jpg&name=large'
        )
      end
      let(:activity) do
        Clients::Vision::Activity.new(
          status.status_id,
          status.tweeted_at,
          '13:51',
          '36.61',
          '0.04'
        )
      end
      let(:message) do
        <<~TEXT
          ・url: https://twitter.com/#{Clients::Twitter::USER_ID}/status/#{activity.status_id}
          ・合計活動時間: #{activity.activity_time}
          ・合計消費カロリー: #{activity.consumption_calory}kcal
          ・合計走行距離: #{activity.running_distance}km
        TEXT
      end

      before do
        allow(Clients::S3).to receive(:list).and_return(["#{persisted_status.status_id}.csv"])
        allow(Clients::Twitter).to receive(:list).and_return([persisted_status, status])
        allow(Clients::Vision).to receive(:show).and_return(activity)
        allow(Clients::S3).to receive(:create)
        allow(Clients::Slack).to receive(:notify)
      end

      it 'returns activities' do
        expect(call).to contain_exactly activity
      end

      it 'returns with Clients::S3.list called' do
        call
        expect(Clients::S3).to have_received(:list).with(no_args)
      end

      it 'returns with Clients::Twitter.list called' do
        call
        expect(Clients::Twitter).to have_received(:list).with(count: 20)
      end

      it 'returns with Clients::Vision.show called' do
        call
        expect(Clients::Vision).to have_received(:show).with(status)
      end

      it 'returns with Clients::S3.create called' do
        call
        expect(Clients::S3).to have_received(:create).with(file_name: "#{activity.status_id}.csv",
                                                           body: activity.to_csv)
      end

      it 'returns with Clients::Slack.notify called' do
        call
        expect(Clients::Slack).to have_received(:notify).with(message)
      end
    end
  end
end
