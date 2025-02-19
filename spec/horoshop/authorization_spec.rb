# frozen_string_literal: true

require 'spec_helper'
require 'pry'
describe Horoshop::Authorization do
  subject { described_class.new(horoshop) }

  let(:horoshop) do
    Horoshop::Client.new(login: 'user123', password: 'pass123', url: 'http://api.horosop.com')
  end

  before do
    allow(horoshop).to receive(:token=)
    allow(horoshop).to receive(:expiration_timestamp=)
    allow(Time).to receive(:now).and_return(Time.parse('2024-02-21 12:42:59 +0200'))
  end

  after { subject.authorize }

  describe '#authorize' do
    context 'when authorization is successful' do
      before do
        stub_request(:post, 'http://api.horosop.com/api/auth/')
          .with(body: { login: 'user123', password: 'pass123' })
          .to_return(
            status: 200,
            body: { 'status' => 'OK', 'response' => { 'token' => '123qwe4' } }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it { expect(horoshop).to receive(:token=).with('123qwe4') }
      it { expect(horoshop).to receive(:expiration_timestamp=).with(Time.parse('2024-02-21 12:42:59 +0200') + 600) }
    end

    context 'when authorization fails' do
      before do
        stub_request(:post, 'http://api.horosop.com/api/auth/')
          .with(body: { login: 'user123', password: 'pass123' })
          .to_return(
            status: 500,
            body: { 'status' => 'HTTP_ERROR', 'message' => 'UNKNOWN SERVER ERROR' }.to_json
          )
      end

      it { expect(horoshop).not_to receive(:token=) }
      it { expect(horoshop).not_to receive(:expiration_timestamp=) }
      it { expect(subject.authorize).to be_a(Object) }
    end
  end
end
