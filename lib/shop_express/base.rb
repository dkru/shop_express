# frozen_string_literal: true

require_relative 'connection'

module ShopExpress
  # base class for all methods used in others classes
  class Base
    include Connection
    attr_reader :shop_express

    STATUS_OK = 'OK'

    # @param shop_express [ShopExpress::Client]
    def initialize(shop_express)
      @shop_express = shop_express
    end
  end
end
