# frozen_string_literal: true

require 'spec_helper'

describe ShopExpress::CatalogExport do
  let(:shop_express) do
    double(:client, url: URI.parse('http://t.com'), login: '', password: '', token: '', token_valid?: true)
  end
  let(:json) { file_fixtures('catalog_export.json') }

  before do
    stub_request(:post, 'http://t.com/api/catalog/export')
      .to_return(
        status: 200,
        body: json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  subject { described_class.new(shop_express) }

  describe '#call' do
    it 'returns list of products' do
      expect(subject.call).to match(JSON.parse(json)['response']['products'])
    end
  end
end
