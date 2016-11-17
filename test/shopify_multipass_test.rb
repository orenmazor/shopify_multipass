require 'test_helper'

class ShopifyMultipassTest < Minitest::Test
  def test_that_we_generate_something_that_looks_like_a_url
    set_shopify_secret

    assert ShopifyMultipass.login_url("whydontyoujust", full_mock_user).start_with?("https://whydontyoujust.myshopify.com/account/login/multipass")
  end

  def test_that_we_raise_a_meaningful_way_when_config_is_missing
    ENV.delete("SHOPIFY_MULTIPASS_SECRET")
    assert_raises ShopifyMultipass::Token::MissingSecret do
      ShopifyMultipass::Token.generate(full_mock_user)
    end
  end

  def test_that_we_force_remote_ip
    set_shopify_secret
    # this seems like a good opinionated thing to do/have
    # but I dont really care
    
    assert_raises Exception do
      ShopifyMultipass::Token.generate(mock_user)
    end
  end

  def test_that_we_can_make_a_token
    set_shopify_secret

    assert ShopifyMultipass::Token.generate(full_mock_user)
  end

  def test_that_we_generate_the_url_to_shopify
  end

  def set_shopify_secret
    ENV["SHOPIFY_MULTIPASS_SECRET"] = SecureRandom.uuid
  end

  def mock_user
    # these are the minimum required fields, minus remote_ip
    {email: SecureRandom.uuid}
  end

  def full_mock_user
    # these are the minimum required fields
    {email: SecureRandom.uuid, remote_ip: SecureRandom.uuid}
  end
end
