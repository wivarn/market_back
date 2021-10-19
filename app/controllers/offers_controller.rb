# frozen_string_literal: true

class OffersController < ApplicationController
  before_action :authenticate!

  def index; end

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
