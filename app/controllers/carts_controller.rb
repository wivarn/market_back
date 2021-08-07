# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :authenticate!
  before_action :validate_address_set!
  before_action :load_cart_through_seller_id, only: %i[add_item checkout delete]

  def index
    carts = current_account.carts.includes(:listings, seller: :address)

    response = carts.map do |cart|
      shipping_rate = shipping_rate_by_country(cart.seller.address.country)
      listings = cart.listings.to_a
      max = listings.delete(listings.max_by { |listing| listing[shipping_rate] })

      cart.serializable_hash.merge(cart.seller.slice(:given_name, :family_name),
                                   total: total(shipping_rate, max, listings),
                                   listings: cart.listings)
    end

    render json: response
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
    shipping_rate = shipping_rate_by_country(@cart.seller.address.country)
    seller_stripe_account = @cart.seller.stripe_connection.stripe_account
    listings = @cart.listings.to_a
    max = listings.delete(listings.max_by { |listing| listing[shipping_rate] })
    total_price = total(shipping_rate, max, listings)
    application_fee_amount = total_price * 0.05 * 100

    order = current_account.purchases.create(seller: @cart.seller, total: total_price)
    order.listings = @cart.listings

    line_items = listings.append(max).each_with_object([]) do |listing, items|
      items << {
        price_data: {
          currency: listing.currency.downcase,
          unit_amount: stripe_subtotal(shipping_rate, listing),
          product_data: {
            name: listing.title
            # description:
            # images:
          }
        },
        quantity: 1
      }
    end

    session = Stripe::Checkout::Session
              .create({
                        client_reference_id: order.id,
                        payment_method_types: ['card'],
                        line_items: line_items,
                        payment_intent_data: {
                          application_fee_amount: application_fee_amount.to_i
                        },
                        mode: 'payment',
                        success_url: "#{ENV['FRONT_END_BASE_URL']}/account/purchaseHistory",
                        cancel_url: "#{ENV['FRONT_END_BASE_URL']}/cart"
                      }, { stripe_account: seller_stripe_account })

    render json: session
  end

  def delete
    @cart.destroy
    render json: { deleted: true }
  end

  def empty_all
    current_account.carts.destroy_all
    render json: { deleted: true }
  end

  private

  def validate_address_set!
    return if current_account.address

    render json: { error: 'You must set your address before you can have a shopping cart' },
           status: :unprocessable_entity
  end

  def shipping_rate_by_country(seller_country)
    current_account.address.country == seller_country ? :domestic_shipping : :international_shipping
  end

  def stripe_subtotal(shipping_rate, listing)
    ((listing.price + listing[shipping_rate]) * 100).to_i
  end

  def total(shipping_rate, max_shipping_listing, listings)
    total_shipping = listings.inject(max_shipping_listing[shipping_rate]) do |sum, listing|
      sum + (listing.combined_shipping || listing[shipping_rate])
    end
    total_listing_price = listings.inject(max_shipping_listing.price) { |sum, listing| sum + listing.price }

    total_shipping + total_listing_price
  end

  def load_cart_through_seller_id
    @cart = Cart.where(account: current_account, seller_id: listing_params[:seller_id]).first_or_create
  end

  def listing_params
    params.permit(:seller_id, :listing_id)
  end
end
