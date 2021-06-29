# frozen_string_literal: true

class CartController < ApplicationController
  before_action :authenticate!
  before_action :load_cart

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
    total_price = 0
    line_items = []
    listings.each do |listing|
      amount = (listing.price + listing.domestic_shipping) * 100
      total_price += amount
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

  def load_cart
    @cart = Cart.where(account: current_account).first_or_create
  end

  def listing_params
    params.permit(:listing_id)
  end
end
