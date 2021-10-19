# frozen_string_literal: true

class OffersController < ApplicationController
  before_action :authenticate!
  before_action :set_listing, only: %i[create]

  def index; end

  def create
    offer = @listing.offers.new(buyer: current_account, amount: params[:amount])
    if offer.save
      render json: OfferBlueprint.render(offer), status: :created
    else
      render json: offer.errors, status: :unprocessable_entity
    end
  end

  private

  def set_listing
    @listing = Listing.active.find(params[:listing_id])
  end
end
