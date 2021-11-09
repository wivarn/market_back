# frozen_string_literal: true

class OfferMailer < ApplicationMailer
  default from: "Skwirl <offers@#{ENV['DOMAIN']}>"

  def offer_received(offer)
    recipient = offer.seller.email
    @offers_link = "#{ENV['FRONT_END_BASE_URL']}/offers"
    @listing_title = offers.listing.title

    mail to: recipient, subject: 'You have received an offer'
  end

  def offer_accepted(offer)
    recipient = offer.buyer.email
    @cart_link = "#{ENV['FRONT_END_BASE_URL']}/cart"

    mail to: recipient, subject: 'Your offer has been accepted'
  end

  def offer_rejected(offer)
    recipient = offer.buyer.email
    @offers_link = "#{ENV['FRONT_END_BASE_URL']}/offers"

    mail to: recipient, subject: 'Your offer has been rejected'
  end

  def offer_cancelled(offer)
    recipient = offer.seller.email
    @offers_link = "#{ENV['FRONT_END_BASE_URL']}/offers"

    mail to: recipient, subject: 'An offer has been cancelled'
  end

  def counter_offer_received(offer)
    recipient = offer.buyer.email
    @offers_link = "#{ENV['FRONT_END_BASE_URL']}/offers"

    mail to: recipient, subject: 'You have received a counter offer'
  end

  def counter_offer_accepted(offer)
    recipient = offer.seller.email
    @offers_link = "#{ENV['FRONT_END_BASE_URL']}/offers"

    mail to: recipient, subject: 'Your counter offer has been accepted'
  end

  def counter_offer_rejected(offer)
    recipient = offer.seller.email
    @offers_link = "#{ENV['FRONT_END_BASE_URL']}/offers"

    mail to: recipient, subject: 'Your counter offer has been rejected'
  end

  def counter_offer_cancelled(offer)
    recipient = offer.buyer.email
    @offers_link = "#{ENV['FRONT_END_BASE_URL']}/offers"

    mail to: recipient, subject: 'A counter offer has been cancelled'
  end
end
