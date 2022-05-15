# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/clients/slack'

RSpec.describe Clients::Slack do
  let(:client) { instance_double(described_class::Client) }

  before { allow(described_class::Client).to receive(:new).and_return(client) }

  describe '.notify' do
    subject(:notify) { described_class.notify(text) }

    let(:text) { 'good text' }
    let(:expected) do
      {
        attachments: [{
          fallback: text,
          title: '本日の運動結果',
          text: text,
          color: 'good'
        }]
      }
    end

    before { allow(client).to receive(:post) }

    it 'returns with client called' do
      notify
      expect(client).to have_received(:post).with(expected)
    end
  end

  describe '.warn' do
    subject(:warn) { described_class.warn(text) }

    let(:text) { 'warn text' }
    let(:expected) do
      {
        attachments: [{
          fallback: text,
          title: '運動結果の取得に失敗しました',
          text: text,
          color: 'warning'
        }]
      }
    end

    before { allow(client).to receive(:post) }

    it 'returns with client called' do
      warn
      expect(client).to have_received(:post).with(expected)
    end
  end
end
