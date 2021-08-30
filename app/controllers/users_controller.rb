# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user
  def show
    render json: AccountBlueprint.render(@user, view: :with_recent_listings,
                                                destination_country: params[:destination_country])
  end

  def listings
    listings = @user.listings.active.ships_to(params[:destination_country] || 'USA').order(updated_at: :desc, id: :asc)
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
      listings.order(price: :asc, id: :asc)
    when 'priceHigh'
      listings.order(price: :desc, id: :asc)
    when 'priceShipLow'
      listings.select('*, (price + domestic_shipping) AS total_price').order(total_price: :asc, id: :asc)
    when 'priceShipHigh'
      listings.select('*, (price + domestic_shipping) AS total_price').order(total_price: :desc, id: :asc)
    when 'newest'
      listings.order(updated_at: :desc, id: :asc)
    when 'oldest'
      listings.order(updated_at: :asc, id: :asc)
    else
      listings
    end
  end
end
