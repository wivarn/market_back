# frozen_string_literal: true

class OfferJob < ApplicationJob
  rate '10 minutes'
  def expire
    Offer.expired_active.includes(:listing).each do |offer|
      offer.expire!
      # Mail
    end
    Offer.expired_accepted.includes(:listing).each do |offer|
      offer.expire!
      offer.listing.cancel_offer!
      # Mail
    end
  end
end
