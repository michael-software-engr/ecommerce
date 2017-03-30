# ... edited by app gen (product resource)

# rubocop:disable Metrics/BlockLength

require 'rails_helper'
require 'mocks/stripe'

RSpec.describe ProductsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) do
    User.create!(
      email: 'store-owner@store-name.com',
      password: 'abcdefgh',
      password_confirmation: 'abcdefgh'
    )
  end

  let(:valid_attributes) do
    {
      name: 'product',
      user: user,
      description: 'description',
      price: 10.01, in_stock: 5,
      sku: 12_345
    }
  end

  let(:valid_session) { {} }

  # ...
  describe 'POST #buy' do
    def mock_stripe(product, stripe_params = nil, customer = nil)
      StripeMock.new product, stripe_params, customer
    end

    let(:product) { Product.create! valid_attributes }

    context 'with invalid params' do
      context 'with invalid Strip::Customer.create params' do
        let(:invalid_stripe_params) { StripeParams.new :invalid, product }

        let(:error_message) do
          'Stripe::CardError:' \
          ' ' \
          'Cannot charge a customer that has no active card'
        end

        describe 'Rails.logger' do
          specify do
            mock_stripe product, invalid_stripe_params.customer

            expect(Rails.logger).to receive(:error).with(error_message)
            post :buy, params: invalid_stripe_params.all, session: valid_session
          end
        end

        describe 'flash[:error]' do
          specify do
            mock_stripe product, invalid_stripe_params.customer

            post :buy, params: invalid_stripe_params.all, session: valid_session
            expect(flash[:error]).to eq error_message
          end
        end

        describe 'redirect' do
          specify do
            mock_stripe product, invalid_stripe_params.customer

            expect(
              post(
                :buy,
                params: invalid_stripe_params.all,
                session: valid_session
              )
            ).to redirect_to products_path
          end
        end
      end
    end

    context 'with valid params' do
      let(:valid_stripe_params) { StripeParams.new :valid, product }

      it 'assigns a product as @product' do
        # Mocking not required to make this spec pass but it's mocked to
        #   make the spec more robust - to make it pass even if we're off-line
        #   and don't have access to the Stripe servers.
        mock_stripe product, valid_stripe_params.customer

        post :buy, params: valid_stripe_params.all, session: valid_session
        expect(assigns(:product)).to be_a(Product)
      end

      it(
        'calls Stripe::Customer.create(**with_correct_args) once and' \
        ' ' \
        'returns a customer'
      ) do
        customer = double id: 5678

        mock_stripe product, valid_stripe_params.customer, customer

        expect(Stripe::Customer).to receive(:create).with(
          email: valid_stripe_params.email, source: valid_stripe_params.token
        ).once.and_return(customer)

        post :buy, params: valid_stripe_params.all, session: valid_session
      end

      it 'calls Stripe::Charge.create(**with_correct_args) once' do
        customer = double id: 1234

        mock_stripe product, valid_stripe_params.customer, customer

        expect(Stripe::Charge).to receive(:create).with(
          customer:    customer.id,
          amount:      product.price.to_i * 100,
          description: "#{product.id}:#{product.name}",
          currency:    'usd'
        ).once

        post :buy, params: valid_stripe_params.all, session: valid_session
      end

      it 'decreases product in_stock by 1 after buying a product' do
        mock_stripe product, valid_stripe_params.customer
        expect do
          post :buy, params: valid_stripe_params.all, session: valid_session
        end.to change { product.reload.in_stock }.by(-1)
      end

      it 'receives notification from stripe of successful purchase'
    end
  end
end
