# frozen_string_literal: true

require 'spec_helper'

describe ShopExpress::ImportResiduences do
  let(:shop_express) do
    double(:client, url: URI.parse('http://t.com'), login: '', password: '', token: '', token_valid?: true)
  end

  before do
    stub_request(:post, 'http://t.com/api/catalog/importResidues/')
      .to_return(
        status: 200,
        body: body,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  subject { described_class.new(shop_express) }

  context 'when valid response received' do
    let(:body) do
      <<-JSON
        {
          "status": "OK",
          "response": {
            "log": [
              {"article": "00090001", "status": "OK", "message": "UPDATED"},
              {"article": "00090002", "status": "OK", "message": "UPDATED"}
            ]
          }
        }
      JSON
    end

    it 'return empty array' do
      expect(subject.call({})).to eq []
    end
  end

  context 'when combined response received' do
    let(:body) do
      <<-JSON
        {
          "status": "ANY",
          "response": {
            "log": [
              {"article": "00090001", "status": "OK", "message": "UPDATED"},
              {"article": "00090002", "status": "OK", "message": "UPDATED"},
              {"article": "00090003", "status": "ERROR", "message": "Warehouse office is not defined"}
            ]
          }
        }
      JSON
    end

    it 'return hash' do
      expect(subject.call({})).to eq [
        { 'article' => '00090003', 'status' => 'ERROR', 'message' => 'Warehouse office is not defined' }
      ]
    end
  end
end
