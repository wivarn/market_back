# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :authenticate!
  before_action :validate_address_set!
  before_action :load_cart_through_seller_id, only: %i[add_item checkout delete]

  def index
    carts = current_account.carts.includes(:listings, seller: :address)
    render json: CartBlueprint.render(carts, destination_country: current_account.address.country)
  end

  def add_item
    cart_item = @cart.cart_items.new(listing_id: listing_params[:listing_id])
    if cart_item.save
      render json: ListingBlueprint.render(cart_item, destination_country: current_account.address.country)
    else
      render json: cart_item.errors, status: :unprocessable_entity
    end
  end

  def checkout
    cart_json = CartBlueprint.render_as_json(@cart, destination_country: current_account.address.country)
    seller_stripe_account = @cart.seller.stripe_connection.stripe_account
    total_price = cart_json['total']
    application_fee_amount = total_price * 0.05 * 100

    order = current_account.purchases.create(seller: @cart.seller, total: total_price)
    order.listings = @cart.listings

    line_items = cart_json['listings'].each_with_object([]) do |listing, items|
      items << {
        price_data: {
          currency: listing['currency'].downcase,
          unit_amount: stripe_subtotal(listing),
          product_data: {
            name: listing['title'],
            images: stripe_images(listing)
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

  def load_cart_through_seller_id
    @cart = Cart.where(account: current_account, seller_id: listing_params[:seller_id]).first_or_create
  end

  def stripe_subtotal(listing)
    ((listing['price'].to_f + listing['shipping'].to_f) * 100).to_i
  end

  def stripe_images(listing)
    return [] if Jets.env.development? || Jets.env.test?

    listing['photos'].take(8).map { |photo| photo['url'] }
  end

  def listing_params
    params.permit(:seller_id, :listing_id)
  end
end
