# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user
  def show
    listings = @user.listings.active.ships_to(params[:ships_to] || 'USA').order(created_at: :desc).limit(4)
    response = @user.slice(:given_name, :family_name, :picture).merge(listings: listings)
    render json: response
  end

  def listings
    listings = @user.listings.active.ships_to(params[:ships_to] || 'USA')
    listings = sort(listings, params[:sort])
    listings = listings.page(params[:page].to_i + 1)

    render json: { listings: listings, total_pages: listings.total_pages }
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
