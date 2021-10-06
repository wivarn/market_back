# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :authenticate!
  before_action :validate_address_set!
  before_action :set_cart_through_seller_id, only: %i[add_item checkout remove_item delete]
  before_action :set_checkout_session, only: %i[add_item checkout remove_item delete]
  before_action :enforce_no_checkout_session!, only: %i[add_item remove_item]
  before_action :continue_checkout, only: %i[checkout]

  def index
    carts = current_account.carts.includes(:listings, :seller)
    render json: CartBlueprint.render(carts, destination_country: current_account.address.country)
  end

  def add_item
    cart_item = @cart.cart_items.new(listing: @cart.seller.listings.active.find(listing_params[:listing_id]))
    if cart_item.save
      render json: CartItemBlueprint.render(current_account.cart_items)
    else
      render json: cart_item.errors, status: :unprocessable_entity
    end
  end

  def checkout
    cart_hash = CartBlueprint.render_as_hash(@cart, destination_country: current_account.address.country)
    application_fee_amount = cart_hash[:total] * @cart.seller.fee

    ActiveRecord::Base.transaction do
      order = current_account.purchases.create(seller: @cart.seller)
      order.address = current_account.address.dup
      # TODO: adding shipping to order_items
      order.listings = @cart.listings
      order.reserve!

      session = Stripe::Checkout::Session
                .create({
                          client_reference_id: order.id,
                          payment_method_types: ['card'],
                          line_items: stripe_line_items(cart_hash[:listings]),
                          payment_intent_data: {
                            application_fee_amount: application_fee_amount.to_i,
                            receipt_email: current_account.email
                          },
                          mode: 'payment',
                          customer_email: current_account.email,
                          success_url: "#{ENV['FRONT_END_BASE_URL']}/account/purchases",
                          cancel_url: "#{ENV['FRONT_END_BASE_URL']}/cart",
                          # need to give a little time for the request to reach Stripe
                          expires_at: Listing::RESERVE_TIME.from_now.to_i + 20
                        }, { stripe_account: @cart.seller.payment.stripe_id })

      @cart.update(checkout_session_id: session.id)
      render json: { url: session.url }
    end
  end

  def remove_item
    @cart.cart_items.delete_by(listing: @cart.seller.listings.find(listing_params[:listing_id]))
    @cart.destroy if @cart.cart_items.empty?
    carts = current_account.carts.includes(:listings, :seller)
    render json: CartBlueprint.render(carts, destination_country: current_account.address.country)
  end

  def delete
    Order.reserved.where(id: @checkout_session.client_reference_id).destroy_all if @checkout_session
    @cart.destroy
    carts = current_account.carts.includes(:listings, :seller)
    render json: CartBlueprint.render(carts, destination_country: current_account.address.country)
  end

  private

  def validate_address_set!
    return if current_account.address

    render json: { error: 'You must set your address before you can have a shopping cart' },
           status: :unprocessable_entity
  end

  def set_cart_through_seller_id
    @cart = Cart.where(buyer: current_account, seller_id: listing_params[:seller_id]).first_or_create
  end

  def set_checkout_session
    return unless @cart.checkout_session_id

    @checkout_session = Stripe::Checkout::Session.retrieve(@cart.checkout_session_id,
                                                           stripe_account: @cart.seller.payment.stripe_id)
    if Time.now.to_i > @checkout_session.expires_at
      @cart.update(checkout_session_id: nil)
      @checkout_session = nil
    end
  rescue Stripe::InvalidRequestError
    @cart.update(checkout_session_id: nil)
    @checkout_session = nil
  end

  def enforce_no_checkout_session!
    return unless @checkout_session

    render json:
      { error: 'You have an active checkout session. Please finish checking out or cancel by emptying your cart.' },
           status: :bad_request
  end

  def continue_checkout
    return unless @checkout_session

    render json: { url: @checkout_session.url }
  end

  def stripe_line_items(listings)
    listings.map do |listing|
      { price_data: {
        currency: listing[:currency].downcase,
        unit_amount: stripe_subtotal(listing),
        product_data: {
          name: listing[:title]
          # images: stripe_images(listing)
        }
      }, quantity: 1 }
    end
  end

  def stripe_subtotal(listing)
    ((listing[:price].to_f + listing[:shipping].to_f) * 100).to_i
  end

  def stripe_images(listing)
    return [] if Jets.env.development? || Jets.env.test?

    listing[:photos].take(8).map { |photo| photo['url'] }
  end

  def listing_params
    params.permit(:seller_id, :listing_id)
  end
end
