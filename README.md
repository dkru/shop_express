This is gem used for exchange data with https://shop-express.ua - internet shop constructor

### Authorization 
At first, you must create instance of class ShopExpress with valid params to connect
After that you just use instance shop_express for all next requests.

    shop_express = ShopExpress::Client.new(url: URI.parse('http://somesite.org'), username: 'jhon', password: 'piterson')
    ShopExpress::Authotization.new(shop_express).authorize
    

### ImportResidues 
Send returns all log data without OK status.
```ruby 
ShopExpress::ImportResidues.new(shop_express).call(hash)
```

### CatalogExport 
Returns all products in the catalog. Possible arguments:
- limit (default 5000)
- offset (default: 0)
- display_in_show_case ("true" - only goods with quantity > 0, "false" all goods)
```ruby
ShopExpress::CatalogExport.new(shop_express).call(limit: 100, offset: 5)
```
