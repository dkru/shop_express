# frozen_string_literal: true

require 'faraday'
module ShopExpress
  # Module for check connection
  module Connection
    ERROR = { 'status' => 'HTTP_ERROR', 'response' => { 'message' => 'UNKNOWN SERVER ERROR' } }.freeze

    def post(shop_express:, url:, body:, add_token: false)
      mixin_token!(shop_express, body) if add_token
      connection(shop_express).post(url, body).body
    rescue Faraday::Error => e
      Rails.logger.error(e) if defined?(Rails)
      ERROR
    end

    def connection(shop_express)
      @connection ||= Faraday.new(url: shop_express.url) do |faraday|
        faraday.request :json
        faraday.response :raise_error
        faraday.response :json
        faraday.adapter Faraday.default_adapter
      end
    end

    def mixin_token!(shop_express, body)
      shop_express.refresh_token! unless shop_express.token_valid?
      body[:token] = shop_express.token
    end
  end
end
