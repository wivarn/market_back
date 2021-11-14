# frozen_string_literal: true

class OffersController < ApplicationController
  before_action :authenticate!
  before_action :set_offer, only: %i[accept reject cancel]
  before_action :set_listing_and_enforce_buyer, only: %i[create]
  before_action :set_offer_and_enforce_seller, only: %i[create_counter]
  before_action :enforce_accept_offers!, only: %i[create create_counter]

  def index
    purchase_offers = current_account.purchase_offers.active_or_accepted.includes(:buyer,
                                                                                  listing: :account).order(:created_at)
    sale_offers = current_account.sales_offers.active_or_accepted.includes(:buyer, listing: :account).order(:created_at)

    render json: {
      purchase_offers: OfferBlueprint.render_as_json(purchase_offers, view: :detailed),
      sale_offers: OfferBlueprint.render_as_json(sale_offers, view: :detailed)
    }
  end

  def create
    offer = @listing.offers.new(buyer: current_account, counter: false, amount: params[:amount])
    if offer.save
      other_active_offers = Offer.active.other_offers(offer)
      other_active_offers.each { |o| o.buyer_reject_or_cancel!(current_account.id) }
      OfferMailer.offer_received(offer).deliver
      render json: OfferBlueprint.render(offer, view: :detailed), status: :created
    else
      render json: offer.errors, status: :unprocessable_entity
    end
  end

  def create_counter
    counter_offer = Offer.new(listing: @offer.listing, buyer: @offer.buyer, counter: true, amount: params[:amount])
    if counter_offer.save
      other_active_offers = Offer.active.other_offers(counter_offer)
      other_active_offers.each { |o| o.seller_reject_or_cancel!(current_account.id) }
      OfferMailer.counter_offer_received(counter_offer).deliver
      render json: OfferBlueprint.render(counter_offer, view: :detailed), status: :created
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
    listing.offer!
    @offer.send_accepted_email
    render json: OfferBlueprint.render(@offer, view: :detailed), status: :accepted
  end

  def reject
    @offer.reject!(current_account.id)
    @offer.send_rejected_email
    render json: OfferBlueprint.render(@offer, view: :detailed), status: :accepted
  end

  def cancel
    @offer.cancel!(current_account.id)
    @offer.send_cancelled_email
    render json: OfferBlueprint.render(@offer, view: :detailed), status: :accepted
  end

  private

  def set_offer
    @offer = Offer.active.find(params[:id])
  end

  def set_listing_and_enforce_buyer
    @listing = Listing.active.ships_to(current_account.address.country).find(params[:listing_id])
    return if @listing.account_id != current_account.id

    render json: { error: 'You cannot make an offer on your own listing' }, status: :forbidden
  end

  def set_offer_and_enforce_seller
    @offer = current_account.sales_offers.active.find(params[:id])
    @listing = @offer.listing
    return if @listing.account_id == current_account.id

    render json: { error: 'You cannot make an offer on your own listing' }, status: :forbidden
  end

  def enforce_accept_offers!
    return if @listing.accept_offers

    render json: { error: 'This listing does not accept offers' }, status: :forbidden
  end
end
