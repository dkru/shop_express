# frozen_string_literal: true

require 'spec_helper'

class ShopExpressConnection
  include ShopExpress::Connection
end

describe ShopExpress::Connection do
  let(:shop_express) do
    double(:client, url: URI.parse('http://t.com'), login: '', password: '', token: '')
  end

  subject  { ShopExpressConnection.new }

  describe '#post' do
    let(:url) { '/api/test' }
    let(:body) { { key: 'value' } }

    context 'when request is successful' do
      before do
        stub_request(:post, "http://t.com#{url}")
          .to_return(
            status: 200,
            body: { 'status' => 'OK', 'response' => { 'token' => '123qwe4' } }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns a success response' do
        response = subject.post(shop_express: shop_express, url: url, body: body)
        expect(response).to include('status' => 'OK')
      end
    end

    context 'when a server error occurs' do
      before do
        stub_request(:post, "http://t.com#{url}")
          .to_return(status: 500, body: nil, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns a server error message' do
        response = subject.post(shop_express: shop_express, url: url, body: body)
        expect(response).to eq(ShopExpress::Connection::ERROR)
      end
    end

    context 'when a server return non json object' do
      before do
        stub_request(:post, "http://t.com#{url}")
          .to_return(status: 302, body: '<html></html>', headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns a server error message' do
        response = subject.post(shop_express: shop_express, url: url, body: body)
        expect(response).to eq(ShopExpress::Connection::ERROR)
      end
    end
  end

  describe '#mixin_token!' do
    let(:url) { '/some/url' }
    before do
      stub_request(:post, "http://t.com#{url}")
        .to_return(
          status: 200,
          body: { 'status' => 'OK', 'response' => { 'token' => '123qwe4' } }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    context 'when refresh token not needed' do
      it 'does not call refresh token' do
        allow(shop_express).to receive(:token_valid?) { true }
        expect(shop_express).not_to receive(:refresh_token!) { true }
        subject.post(shop_express: shop_express, url: url, body: {}, add_token: true)
      end
    end

    context 'when refresh token needed' do
      it 'just call refresh token' do
        allow(shop_express).to receive(:token_valid?) { false }
        expect(shop_express).to receive(:refresh_token!) { true }
        subject.post(shop_express: shop_express, url: url, body: {}, add_token: true)
      end
    end

    it 'token added to object' do
      allow(shop_express).to receive(:token_valid?) { true }
      allow(shop_express).to receive(:refresh_token!)
      body = { data: 'some_data' }
      expect { subject.mixin_token!(shop_express, body) }
        .to change { body }.to({ data: 'some_data', token: '' })
    end
  end
end
