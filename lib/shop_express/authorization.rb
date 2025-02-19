# frozen_string_literal: true

require_relative 'connection'

module ShopExpress
  # Class for user authorization
  class Authorization < ::ShopExpress::Base
    AUTH_URL = '/api/auth/'
    EXPIRATION_TIME = 600

    def authorize
      response = post(shop_express: shop_express, url: AUTH_URL, body: body)
      return response unless response['status'] == 'OK'

      shop_express.token = response.dig('response', 'token')
      shop_express.expiration_timestamp = Time.now + EXPIRATION_TIME
      response
    end

    private

    attr_reader :shop_express

    def body
      { login: shop_express.login, password: shop_express.password }
    end
  end
end
