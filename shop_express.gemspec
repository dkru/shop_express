# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'shop_express'
  s.version     = '0.0.3'
  s.summary     = 'ShopExpress API interface'
  s.description = 'Gem for exchange data with the internet shop CMS'
  s.authors     = ['Denys Krupenov']
  s.email       = 'dkru84@gmail.com'
  s.files = Dir['lib/**/*', 'LICENSE', 'README.md']
  s.require_paths = 'lib'
  s.homepage    = 'https://github.com/dkru/shop_express'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.6.1'

  s.metadata = {
    'rubygems_mfa_required' => 'true'
  }
  s.add_dependency 'faraday', '~> 2.8'
end
