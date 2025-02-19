# frozen_string_literal: true

require 'spec_helper'

class HoroshopConnection
  include Horoshop::Connection
end

describe Horoshop::Connection do
  let(:horoshop) do
    double(:client, url: URI.parse('http://t.com'), login: '', password: '', token: '')
  end

  subject  { HoroshopConnection.new }

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
        response = subject.post(horoshop: horoshop, url: url, body: body)
        expect(response).to include('status' => 'OK')
      end
    end

    context 'when a server error occurs' do
      before do
        stub_request(:post, "http://t.com#{url}")
          .to_return(status: 500, body: nil, headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns a server error message' do
        response = subject.post(horoshop: horoshop, url: url, body: body)
        expect(response).to eq(Horoshop::Connection::ERROR)
      end
    end

    context 'when a server return non json object' do
      before do
        stub_request(:post, "http://t.com#{url}")
          .to_return(status: 302, body: '<html></html>', headers: { 'Content-Type' => 'application/json' })
      end

      it 'returns a server error message' do
        response = subject.post(horoshop: horoshop, url: url, body: body)
        expect(response).to eq(Horoshop::Connection::ERROR)
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
        allow(horoshop).to receive(:token_valid?) { true }
        expect(horoshop).not_to receive(:refresh_token!) { true }
        subject.post(horoshop: horoshop, url: url, body: {}, add_token: true)
      end
    end

    context 'when refresh token needed' do
      it 'just call refresh token' do
        allow(horoshop).to receive(:token_valid?) { false }
        expect(horoshop).to receive(:refresh_token!) { true }
        subject.post(horoshop: horoshop, url: url, body: {}, add_token: true)
      end
    end

    it 'token added to object' do
      allow(horoshop).to receive(:token_valid?) { true }
      allow(horoshop).to receive(:refresh_token!)
      body = { data: 'some_data' }
      expect { subject.mixin_token!(horoshop, body) }
        .to change { body }.to({ data: 'some_data', token: '' })
    end
  end
end
