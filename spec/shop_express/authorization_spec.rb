# frozen_string_literal: true

require 'spec_helper'
require 'pry'
describe ShopExpress::Authorization do
  subject { described_class.new(shop_express) }

  let(:shop_express) do
    ShopExpress::Client.new(login: 'user123', password: 'pass123', url: 'http://api.shopexpress.com')
  end

  before do
    allow(shop_express).to receive(:token=)
    allow(shop_express).to receive(:expiration_timestamp=)
    allow(Time).to receive(:now).and_return(Time.parse('2025-02-26 23:23:35 +0200'))
  end

  after { subject.authorize }

  describe '#authorize' do
    context 'when authorization is successful' do
      before do
        stub_request(:post, 'http://api.shopexpress.com/api/auth/')
          .with(body: { login: 'user123', password: 'pass123' })
          .to_return(
            status: 200,
            body: { 'status' => 'OK', 'response' => { 'token' => '123qwe4' } }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it { expect(shop_express).to receive(:token=).with('123qwe4') }
      it { expect(shop_express).to receive(:expiration_timestamp=).with(Time.parse('2025-02-26 23:23:35 +0200') + 600) }
    end

    context 'when authorization fails' do
      before do
        stub_request(:post, 'http://api.shopexpress.com/api/auth/')
          .with(body: { login: 'user123', password: 'pass123' })
          .to_return(
            status: 500,
            body: { 'status' => 'ERROR', 'message' => 'Incorrect input data (login or password).' }.to_json
          )
      end

      it { expect(shop_express).not_to receive(:token=) }
      it { expect(shop_express).not_to receive(:expiration_timestamp=) }
      it { expect(subject.authorize).to be_a(Object) }
    end
  end
end
