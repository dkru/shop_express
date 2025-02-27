# frozen_string_literal: true

module ShopExpress
  # import_residues to the shop_express
  class ImportResiduences < ::ShopExpress::Base
    URL = 'api/catalog/importResidues/'

    # @param body [Hash]
    def call(body)
      body = post(shop_express: shop_express, url: URL, body: body, add_token: true)
      parse_response(body)
    end

    private

    def parse_response(body)
      log = body.dig('response', 'log')
      return [] unless log

      log.filter { |el| el['status'] != STATUS_OK }
    end
  end
end
