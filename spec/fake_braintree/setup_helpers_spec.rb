require 'spec_helper'
require 'zlib'
require 'active_support/gzip'

module FakeBraintree
  class TestClass
    include SetupHelpers
  end
end

describe FakeBraintree::SetupHelpers do
  it 'identifies a non-test user' do
    cls = FakeBraintree::TestClass.new
    expect(cls.is_test_user('nonsense_id')).to be false
  end

  it 'expects a test user environment variable' do
    cls = FakeBraintree::TestClass.new
    expect(cls.test_user_id).to be_a_kind_of(String)
  end

  it 'identifies a test user' do
    cls = FakeBraintree::TestClass.new
    expect(cls.is_test_user(cls.test_user_id)).to be true
  end

  it 'does not create a test customer if the user ID is not the test one' do
    cls = FakeBraintree::TestClass.new
    customer = cls.create_customer_if_test_user('nonsense_id', {})
    expect(customer).to be_nil
  end

  it 'creates a test customer' do
    cls = FakeBraintree::TestClass.new
    customer_response = cls.create_test_customer({id: cls.test_user_id})
    customer_xml = ActiveSupport::Gzip.decompress(customer_response[2])
    customer = Hash.from_xml(customer_xml)["customer"]
    expect(customer["id"]).to eql(cls.test_user_id)
  end

  it 'creates a test payment method' do
    cls = FakeBraintree::TestClass.new
    payment_method_response = cls.create_test_payment_method({customer_id: cls.test_user_id})
    payment_method_xml = ActiveSupport::Gzip.decompress(payment_method_response[2])
    payment_method = Hash.from_xml(payment_method_xml)["credit_card"]
    expect(payment_method["nonce"]).to eql(cls.test_payment_method[:nonce])
    expect(payment_method["customer_id"]).to eql(cls.test_user_id)
  end

  it 'creates a test customer if the test user ID is given' do
    cls = FakeBraintree::TestClass.new
    customer = cls.create_customer_if_test_user(cls.test_user_id, {})
    expect(customer['id']).to eq(cls.test_user_id)
    expect(customer['credit_cards']).not_to be_empty
  end
end
