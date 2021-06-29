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

  def checkout; end

  private

  def load_cart
    @cart = Cart.where(account: current_account).first_or_create
  end

  def listing_params
    params.permit(:listing_id)
  end
end
