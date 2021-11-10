# frozen_string_literal: true

class Offer < ApplicationRecord
  include AASM

  EXPIRY_TIME = 48.hours

  belongs_to :listing
  # belongs to seller through listing
  delegate :seller, to: :listing
  belongs_to :buyer, class_name: 'Account'

  validates :listing, :buyer, :aasm_state, :amount, presence: true
  validates :amount, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ }
  validates :amount, numericality: {
    greater_than_or_equal_to: 1,
    less_than: 100_000_000
  }
  validate :buyer_cannot_be_seller

  aasm timestamps: true, no_direct_assignment: true do
    state :active, initial: true
    state :accepted, :rejected, :cancelled

    event :accept do
      transitions from: :active, to: :accepted, guards: %i[active? can_accept?]
    end

    event :reject do
      transitions from: :active, to: :rejected, guards: %i[active? can_accept?]
    end

    event :cancel do
      transitions from: :active, to: :cancelled, guards: %i[active? can_cancel?]
    end
  end

  scope :active, -> { where('offers.aasm_state = ? AND offers.created_at >= ?', :active, DateTime.now - EXPIRY_TIME) }
  scope :expired, -> { where('offers.aasm_state = ? AND offers.created_at < ?', :active, DateTime.now - EXPIRY_TIME) }
  scope :other_offers, lambda { |offer|
                         where('offers.listing_id = ? AND offers.buyer_id = ? AND offers.id != ?',
                               offer.listing_id, offer.buyer_id, offer.id)
                       }

  def active?
    aasm_state == 'active' && (created_at >= DateTime.now - EXPIRY_TIME)
  end

  def expired?
    aasm_state == 'active' && (created_at < DateTime.now - EXPIRY_TIME)
  end

  def expires_at
    created_at + EXPIRY_TIME
  end

  def buyer_reject_or_cancel!(account_id)
    counter ? reject!(account_id) : cancel!(account_id)
  end

  def seller_reject_or_cancel!(account_id)
    counter ? cancel!(account_id) : reject!(account_id)
  end

  def buyer_cannot_be_seller
    errors.add(:buyer, "buyer can't be the same as seller") if buyer_id == seller.id
  end

  def send_accepted_email
    counter ? OfferMailer.counter_offer_accepted(self).deliver : OfferMailer.offer_accepted(self).deliver
  end

  def send_cancelled_email
    counter ? OfferMailer.counter_offer_cancelled(self).deliver : OfferMailer.offer_cancelled(self).deliver
  end

  def send_rejected_email
    counter ? OfferMailer.counter_offer_rejected(self).deliver : OfferMailer.offer_rejected(self).deliver
  end

  private

  def can_accept?(account_id)
    (counter && account_id == buyer_id) || (!counter && account_id == seller.id)
  end

  def can_cancel?(account_id)
    (counter && account_id == seller.id) || (!counter && account_id == buyer_id)
  end
end
