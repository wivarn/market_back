# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :authenticate!
  before_action :validate_address_set!
  before_action :load_cart_through_seller_id, only: %i[add_item checkout remove_item delete]

  def index
    # TODO: add some logic here to check for empty or stale carts
    carts = current_account.carts.includes(:listings, seller: :address)
    render json: CartBlueprint.render(carts, destination_country: current_account.address.country)
  end

  def add_item
    # TODO: add guards in here to ensure the listing_id matches the seller and check listing aasm_state
    cart_item = @cart.cart_items.new(listing_id: listing_params[:listing_id])
    if cart_item.save
      render json: cart_item
    else
      render json: cart_item.errors, status: :unprocessable_entity
    end
  end

  def checkout
    cart_json = CartBlueprint.render_as_json(@cart, destination_country: current_account.address.country)
    seller_stripe_account = @cart.seller.stripe_connection.stripe_account
    total_price = cart_json['total']
    application_fee_amount = total_price * 0.05 * 100

    ActiveRecord::Base.transaction do
      order = current_account.purchases.create(seller: @cart.seller, total: total_price)
      order.listings = @cart.listings
      order.reserve!

      line_items = cart_json['listings'].each_with_object([]) do |listing, items|
        items << {
          price_data: {
            currency: listing['currency'].downcase,
            unit_amount: stripe_subtotal(listing),
            product_data: {
              name: listing['title']
              # TODO
              # images: stripe_images(listing)
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
  end

  def remove_item
    # TODO: add guards in here to ensure the listing_id matches the seller and check listing aasm_state
    @cart.cart_items.delete_by(listing_id: listing_params[:listing_id])
    render json: { deleted: true }
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

  # TODO
  # def stripe_images(listing)
  #   return [] if Jets.env.development? || Jets.env.test?

  #   listing['photos'].take(8).map { |photo| photo['url'] }
  # end

  def listing_params
    params.permit(:seller_id, :listing_id)
  end
end
