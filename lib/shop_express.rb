# frozen_string_literal: true

require_relative 'shop_express/base'
require_relative 'shop_express/connection'
require_relative 'shop_express/authorization'
require_relative 'shop_express/import_residues'

module ShopExpress
  # Base class used to store data about authentication
  class Client
    attr_accessor :url, :login, :password, :token, :expiration_timestamp

    # @param {URI} url
    # @param {String} login
    # @param {String}
    def initialize(url:, login:, password:)
      @url = url
      @login = login
      @password = password
      @token = nil
      @expiration_timestamp = nil
    end

    def token_valid?
      return false if token.nil?

      expiration_timestamp < Time.now
    end

    def refresh_token!
      ShopExpress::Authorization.new(self).authorize
    end
  end
end
