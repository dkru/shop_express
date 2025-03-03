# frozen_string_literal: true

module ShopExpress
  # get list of the products from the shop_express
  class CatalogExport < ::ShopExpress::Base
    URL = '/api/catalog/export'

    # @param limit [Integer]
    # @param offset [Integer]
    # @param display_in_show_case [String] possible values (false, true)
    def call(limit: 500, offset: 0, display_in_show_case: 'false')
      request_body = {
        limit: limit,
        offset: offset,
        display_in_showcase: display_in_show_case
      }

      response_body = post(shop_express: shop_express, url: URL, body: request_body, add_token: true)
      parse_response(response_body)
    end

    private

    def parse_response(body)
      return [] if body['status'] != STATUS_OK

      body.dig('response', 'products')
    end
  end
end
