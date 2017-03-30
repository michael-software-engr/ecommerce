# ... edited by app gen (product resource)

class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :buy, :setup_purchase]

  def setup_purchase
    @publishable_key = Rails.configuration.stripe.fetch :publishable_key

    # For use with redirecting "back" inside buy action
    session[:setup_purchase_referrer] = request.referer
  end

  # POST /products/1
  def buy
    token = params[:token].freeze
    customer = Stripe::Customer.create(
      email: token[:email], source: token[:id]
    )

    Stripe::Charge.create(
      customer:    customer.id,
      amount:      (@product.price.to_f * 100).to_i,
      description: "#{@product.id}:#{@product.name}",
      currency:    'usd'
    )

    # ... robustify: wait until we receive confirmation from Stripe
    #   that the purchase succeeded before decrementing stock.
    #   Also, add a purchase quantity in the view and reflect that here
    #   instead of hard-coding the number (1 in this case).
    @product.update(in_stock: @product.in_stock - 1)

    @product.update(user: current_user) if current_user

    flash[:successful_purchase] = @product.attributes

    # currency = view_context.number_to_currency @product.price
    # flash[:success] = 'Thank you for purchasing' \
    #   " '#{@product.name}' for '#{currency}'."
  rescue Stripe::CardError => exc
    msg = "#{exc.class}: #{exc.message}"
    Rails.logger.error(msg)
    flash[:error] = msg
  ensure
    # We can't because one more level of redirection (the setup)
    # The "back" is actually purchasing the thing. For example...
    #   redirect_back fallback_location: products_url
    # That's why we have to use session
    redirect_to(session[:setup_purchase_referrer] || products_url)
  end

  # GET /products
  def index
    # ... flash and order edit
    #     flash.keep because because redirected 2x (setup_purchase => buy)???
    flash.keep if request.referer =~ /setup_purchase/

    @current_page_number = (params[:page] || 1).to_i
    @all_products = Product.order(:name)
    @products = @all_products.page(@current_page_number).per(8)

    @special_offers = [@all_products.first, @all_products.last]

    # ... can't cache. If we do, flash won't work.
    #     (Try buying something, the redirect back to the
    #       page won't show purchase confirmation.)
    # return if !Rails.env.production?
    # expires_in 1.year, public: true, must_revalidate: true
  end

  # GET /products/1
  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def product_params
    params.require(:product).permit(
      :name, :description, :price, :in_stock, :sku, :media
    )
  end
end
