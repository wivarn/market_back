# frozen_string_literal: true

class OfferJob < ApplicationJob
  rate '10 minutes'
  def expire
    Offer.expired_active.includes(:listing).each do |offer|
      offer.expire!
      OfferMailer.offer_expired_buyer(offer).deliver
      OfferMailer.offer_expired_seller(offer).deliver
    end
    Offer.expired_accepted.includes(:listing).each do |offer|
      offer.expire!
      offer.listing.cancel_offer!
      OfferMailer.offer_expired_buyer(offer).deliver
      OfferMailer.offer_expired_seller(offer).deliver
      OfferMailer.offer_expired_internal(offer).deliver
    end
  end

  rate '10 minutes'
  def reminder
    Offer.one_day_reminder.includes(:listing).each do |offer|
      offer.send_reminder_email
      offer.update(last_reminder_at: DateTime.now)
    end
    Offer.two_hour_reminder.includes(:listing).each do |offer|
      offer.send_reminder_email
      offer.update(last_reminder_at: DateTime.now)
    end
  end
end
