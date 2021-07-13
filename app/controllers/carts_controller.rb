# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :authenticate!
  before_action :validate_address_set!
  before_action :validate_listing_active, only: %i[validate_listing_active]
  before_action :load_cart_through_seller_id, only: %i[add_item checkout]

  def index
    carts = current_account.carts.includes(:listings, seller: :address)

    response = carts.map do |cart|
      cart.serializable_hash.merge(cart.seller.slice(:given_name, :family_name),
                                   total: total(cart.seller.address, cart.listings),
                                   listings: cart.listings)
    end

    render json: response
  end

  def show
    listings = @cart.listings

    render json: listings
  end

  def add_item
    cart_item = @cart.cart_items.new(listing_id: listing_params[:listing_id])
    if cart_item.save
      render json: cart_item
    else
      render json: cart_item.errors, status: :unprocessable_entity
    end
  end

  def checkout
    listings = @cart.listings
    seller_address = listings.first.account.address
    total_price = total(seller_address, listings)
    line_items = []
    listings.each do |listing|
      amount = subtotal(seller_address, listing)
      line_items << {
        name: listing.title,
        amount: amount.to_i,
        currency: listing.currency.downcase,
        quantity: 1
      }
    end

    application_fee_amount = total_price * 0.05

    stripe_account = listings.first.account.stripe_connection.stripe_account

    session = Stripe::Checkout::Session
              .create({
                        payment_method_types: ['card'],
                        line_items: line_items,
                        payment_intent_data: {
                          application_fee_amount: application_fee_amount.to_i
                        },
                        mode: 'payment',
                        success_url: "#{ENV['FRONT_END_BASE_URL']}/account/purchaseHistory",
                        cancel_url: "#{ENV['FRONT_END_BASE_URL']}/cart"
                      }, { stripe_account: stripe_account })

    render json: session
  end

  private

  def validate_address_set!
    return if current_account.address

    render json: { error: 'You must set your address before you can have a shopping cart' },
           status: :unprocessable_entity
  end

  def subtotal(seller_address, listing)
    shipping = current_account.address.country == seller_address.country ? :domestic_shipping : :international_shipping
    (listing.price + listing.public_send(shipping)) * 100
  end

  def total(seller_address, listings)
    shipping = current_account.address.country == seller_address.country ? :domestic_shipping : :international_shipping
    listing_prices = listings.map(&:price)
    shipping_prices = listings.map(&shipping)
    (listing_prices + shipping_prices).inject(0) { |sum, price| sum + price }
  end

  def validate_listing_active
    listing = Listing.find(listing_params[:listing_id])

    render json: { error: 'Listing is no longer availbile' }, status: :unprocessable_entity unless listing.active?
  end

  def load_cart_through_seller_id
    @cart = Cart.where(account: current_account, seller_id: listing_params[:seller_id]).first_or_create
  end

  def listing_params
    params.permit(:seller_id, :listing_id)
  end
end
