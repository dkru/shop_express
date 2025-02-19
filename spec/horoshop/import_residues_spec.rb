# frozen_string_literal: true

require 'spec_helper'

describe Horoshop::ImportResiduences do
  let(:horoshop) do
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

  subject { described_class.new(horoshop) }

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
              {"article": "00090003", "status": "ERROR", "message": "Warehouse affice is not defined"}
            ]
          }
        }
      JSON
    end

    it 'return hash' do
      expect(subject.call({})).to eq [
        { 'article' => '00090003', 'status' => 'ERROR', 'message' => 'Warehouse affice is not defined' }
      ]
    end
  end
end
