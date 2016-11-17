require "shopify_multipass/version"
require "shopify_multipass/token"

module ShopifyMultipass
  def self.login_url(shopify_domain, customer_hash)
    token = ShopifyMultipass::Token.generate(customer_hash)

    "https://#{shopify_domain}.myshopify.com/account/login/multipass/#{token.to_s}"
  end
end
