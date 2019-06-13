require 'fake_braintree/customer'

module FakeBraintree
  module SetupHelpers

    TEST_USER_ENV_VAR = 'TEST_USER_ID'

    def test_payment_method
      {
          'nonce': 'fake-valid-no-billing-address-nonce'
      }
    end

    def create_customer_if_test_user(user_id, options)
      if is_test_user(user_id)
        create_test_customer(options.merge({id: user_id}))
        create_test_payment_method(options.merge({customer_id: user_id}))
      end

      FakeBraintree.registry.customers[user_id.to_s]
    end

    def is_test_user(user_id)
      test_user_id == user_id
    end

    def test_user_id
      ENV[TEST_USER_ENV_VAR]
    end

    def create_test_customer(options)
      Customer.new({}, options).create
    end

    def create_test_payment_method(options)
      credit_card_hash = test_payment_method
      CreditCard.new(credit_card_hash, options).create
    end
  end
end
