# frozen_string_literal: true

class OffersController < ApplicationController
  before_action :authenticate!
  before_action :set_offer, only: %i[accept reject cancel]

  def purchase_offers
    offers = current_account.purchase_offers.active.includes(:buyer, listing: :account)
    render json: OfferBlueprint.render(offers)
  end

  def sale_offers
    offers = current_account.sales_offers.active.includes(:buyer, listing: :account)
    render json: OfferBlueprint.render(offers)
  end

  def create
    destination_country = current_account.address.country
    listing = Listing.active.ships_to(destination_country).find(params[:listing_id])
    shipping = listing.shipping(destination_country: destination_country)
    offer = listing.offers.new(buyer: current_account, counter: false, destination_country: destination_country,
                               currency: listing.currency, shipping: shipping, amount: params[:amount])
    if offer.save
      active_offers = listing.offers.active.where('offers.buyer_id = ? AND offers.id != ?', current_account.id,
                                                  offer.id)
      active_offers.each { |o| o.cancel!(current_account.id) }
      render json: OfferBlueprint.render(offer), status: :created
    else
      render json: offer.errors, status: :unprocessable_entity
    end
  end

  def create_counter
    offer = current_account.sales_offers.active.find(params[:id])
    listing = offer.listing
    destination_country = offer.destination_country
    shipping = listing.shipping(destination_country: destination_country)
    counter_offer = listing.offers.new(buyer: offer.buyer, counter: true, destination_country: destination_country,
                                       currency: listing.currency, shipping: shipping, amount: params[:amount])
    if counter_offer.save
      active_offers = listing.offers.active.where('offers.buyer_id = ? AND offers.id != ?', offer.buyer_id,
                                                  counter_offer.id)
      active_offers.each { |o| o.reject!(current_account.id) }
      render json: OfferBlueprint.render(counter_offer), status: :created
    else
      render json: counter_offer.errors, status: :unprocessable_entity
    end
  end

  def accept
    @offer.accept!(current_account.id)
    listing = @offer.listing
    cart = Cart.where(buyer: @offer.buyer_id, seller_id: listing.account_id).first_or_create
    cart_item = cart.cart_items.new(listing: listing)
    cart_item.save
    listing.offered!
    render json: OfferBlueprint.render(@offer), status: :accepted
  end

  def reject
    @offer.reject!(current_account.id)
    render json: OfferBlueprint.render(@offer), status: :accepted
  end

  def cancel
    @offer.cancel!(current_account.id)
    render json: OfferBlueprint.render(@offer), status: :accepted
  end

  private

  def set_offer
    @offer = Offer.active.find(params[:id])
  end
end
