# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user
  def show
    render json: AccountBlueprint.render(@user, view: :with_recent_listings,
                                                destination_country: params[:destination_country])
  end

  def listings
    listings = @user.listings.active.ships_to(params[:destination_country] || 'USA')
    listings = sort(listings, params[:sort])
    listings = listings.page(params[:page].to_i + 1)

    render json:
      { listings: ListingBlueprint.render_as_json(listings, destination_country: params[:destination_country]),
        total_pages: listings.total_pages }
  end

  private

  def set_user
    @user = Account.find(params[:user_id])
  end

  def sort(listings, order)
    case order
    when 'priceLow'
      listings.order(price: :asc)
    when 'priceHigh'
      listings.order(price: :desc)
    when 'priceShipLow'
      listings.select('*, (price + domestic_shipping) AS total_price').order(total_price: :asc)
    when 'priceShipHigh'
      listings.select('*, (price + domestic_shipping) AS total_price').order(total_price: :desc)
    when 'newest'
      listings.order(created_at: :desc)
    when 'oldest'
      listings.order(created_at: :asc)
    else
      listings
    end
  end
end
