Pod::Spec.new do |s|
  s.name             = 'CBCrypto'
  s.version          = '0.1.0'
  s.summary          = 'A simple crypto library'
  s.description      = 'A simple crypto library. Developed by Coinbase Wallet team.'

  s.homepage         = 'https://github.com/CoinbaseWallet/CBCrypto'
  s.license          = { :type => "AGPL-3.0-only", :file => 'LICENSE' }
  s.author           = { 'Coinbase' => 'developer@toshi.org' }
  s.source           = { :git => 'https://github.com/CoinbaseWallet/CBCrypto.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/coinbase'

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files = 'ios/Source/**/*.swift'

  s.dependency 'CryptoSwift', '~> 1.0.0'
  s.dependency 'CBCore'
end
