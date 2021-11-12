# frozen_string_literal: true

class OfferJob < ApplicationJob
  rate '5 minutes'
  def expire
    Offer.to_expire.includes(:listing).each do |offer|
      offer.expire!
      # Mail
    end
  end
end
