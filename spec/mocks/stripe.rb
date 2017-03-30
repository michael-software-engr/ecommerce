# ... edited by app gen (product resource)

require 'rspec/mocks/standalone'

class StripeMock
  include RSpec::Mocks::ExampleMethods

  # This is what Stripe returns if params
  #   { stripeEmail: nil, stripeToken: nil } are nil
  STRIPE_INVALID_CUSTOMER_TOKEN = 'cus_9ghGSYuYfdSzfH'.freeze

  private_constant :STRIPE_INVALID_CUSTOMER_TOKEN

  def initialize(product, stripe_params = nil, customer = nil)
    customer ||= customer_get stripe_params
    allow(Stripe::Customer).to receive(:create) { customer }

    allow(Stripe::Charge).to receive(:create).with(
      customer:    customer.id,
      amount:      product.price.to_i * 100,
      description: "#{product.id}:#{product.name}",
      currency:    'usd'
    ) do
      if customer.id == STRIPE_INVALID_CUSTOMER_TOKEN
        raise Stripe::CardError.new(
          'Cannot charge a customer that has no active card',
          Object.new,
          Object.new
        )
      end
    end
  end

  private

  def invalid_customer
    double id: STRIPE_INVALID_CUSTOMER_TOKEN
  end

  def customer_get(stripe_params)
    tkey = :token
    token = stripe_params[tkey]

    if !token
      raise "'#{tkey}' key must exist within Stripe params #{stripe_params}"
    end

    %i[email id].each do |key|
      raise "key #{key} must be present" if !token.key? key
    end

    return invalid_customer if !token[:email] and !token[:id]
    return double id: 1234
  end
end

class StripeParams
  attr_reader :customer, :all, :email, :token

  def initialize(validity, product)
    @email = 'email@example.com'.freeze
    @token = 'abcd1234'.freeze

    if validity == :valid
      @customer = { token: {
        email: @email, id: @token
      } }
    elsif validity == :invalid
      @customer = { token: { email: nil, id: nil } }.freeze
    else
      raise "Invalid validity '#{validity}'"
    end

    @all = @customer.merge(id: product.to_param).freeze
  end
end
