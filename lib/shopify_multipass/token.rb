require 'byebug'
require "openssl"
require 'json'
require 'base64'

module ShopifyMultipass
  class Token
    class MissingSecret < RuntimeError; end

    def self.generate(customer_hash)
      if ENV["SHOPIFY_MULTIPASS_SECRET"].to_s.empty?
        raise MissingSecret.new("You need to get your multipass secret from shopify and put it into your ENV as SHOPIFY_MULTIPASS_SECRET")
      end

      if customer_hash[:remote_ip].to_s.empty?
        raise "You really should set the remote_ip on your customer data"
      end

      customer_hash[:created_at] = Time.now.iso8601

      # cheerfully stolen from https://help.shopify.com/api/reference/multipass
      # and de-DRY'd up because reasons.
      key_material = OpenSSL::Digest.new("sha256").digest(ENV["SHOPIFY_MULTIPASS_SECRET"])
      cipher = OpenSSL::Cipher::Cipher.new("aes-128-cbc")
      cipher.encrypt
      cipher.key = key_material[ 0,16]
      ### Use a random IV
      cipher.iv = iv = cipher.random_iv

      ### Use IV as first block of ciphertext
      ciphertext = iv + cipher.update(customer_hash.to_json) + cipher.final

      signature_key  = key_material[16,16]
      signature = OpenSSL::HMAC.digest("sha256", signature_key, ciphertext)

      Base64.urlsafe_encode64(ciphertext + signature)
    end

    private

    def self.encrypt(plaintext)
      cipher = OpenSSL::Cipher::Cipher.new("aes-128-cbc")
      cipher.encrypt
      cipher.key = @encryption_key

      ### Use a random IV
      cipher.iv = iv = cipher.random_iv

      ### Use IV as first block of ciphertext
      iv + cipher.update(plaintext) + cipher.final
    end
  end
end
