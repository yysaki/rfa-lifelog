# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/clients/vision'
require_relative '../../lib/clients/twitter'

RSpec.describe Clients::Vision do
  describe '.show' do
    subject(:show) { described_class.show(status) }

    let(:url) { 'https://example.com/media/FSNMwAuVIAIj89B.jpg' }
    let(:status) { Clients::Twitter::Status.new(1_523_145_488_362_393_601, '2022-05-08T03:39:17Z', [url]) }
    let(:description) do
      <<~DESCRIPTION
        R 画面を撮影する
        本日の運動結果
        キミとプライム
        13分51秒
        合計活動時間
        36.61kcal
        合計消費力ロリー
        0.04km
        合計走行距離
        小
        次へ
      DESCRIPTION
    end
    let(:expected) do
      {
        status_id: status.status_id,
        tweeted_at: status.tweeted_at,
        activity_time: '13:51',
        consumption_calory: '36.61',
        running_distance: '0.04'
      }
    end
    let(:client) { instance_double(described_class::Client) }

    before do
      allow(described_class::Client).to receive(:new).and_return(client)
      allow(client).to receive(:text_detection).and_return(description)
    end

    it 'returns with client called' do
      show
      expect(client).to have_received(:text_detection).with(url: url)
    end

    it 'returns Activity instance' do
      expect(show).to be_a described_class::Activity
    end

    it 'returns expected value' do
      expect(show.to_h).to eq expected
    end
  end
end
