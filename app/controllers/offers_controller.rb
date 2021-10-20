# frozen_string_literal: true

class OffersController < ApplicationController
  before_action :authenticate!

  def index
    offers = current_account.purchase_offers.active.includes(:buyer, listing: :account)
    render json: OfferBlueprint.render(offers)
  end

  def sales_offers
    offers = current_account.sales_offers.active.includes(:buyer, listing: :account)
    render json: OfferBlueprint.render(offers)
  end

  def create
    destination_country = current_account.address.country
    listing = Listing.active.ships_to(destination_country).find(params[:listing_id])
    shipping = listing.shipping(destination_country: destination_country)
    offer = listing.offers.new(buyer: current_account, amount: params[:amount],
                               destination_country: destination_country, currency: listing.currency, shipping: shipping)
    if offer.save
      render json: OfferBlueprint.render(offer), status: :created
    else
      render json: offer.errors, status: :unprocessable_entity
    end
  end
end
