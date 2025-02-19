This is gem used for exchange data with shop-express.ua internet shop constructor

Authorization usage, at first you must create instance of class ShopExpress with valid params to connect
After that you just use instance shop_express for all next requests.

    shop_express = ShopExpress::Client.new(url: URI.parse('http://somesite.org'), username: 'jhon', password: 'piterson')
    
    ShopExpress::Authotization.new(shop_express).authorize
    ShopExpress::ImportResidues.new(shop_express).import(hash)

*ImportResidues* returns all log data without OK status.
