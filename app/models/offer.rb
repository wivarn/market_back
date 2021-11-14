# frozen_string_literal: true

class Offer < ApplicationRecord
  include AASM

  EXPIRY_TIME = 2.days
  ONE_DAY_BEFORE_EXPIRY = EXPIRY_TIME - 1.day
  TWO_HOURS_BEFORE_EXPIRY = EXPIRY_TIME - 2.hours

  belongs_to :listing
  # belongs to seller through listing
  delegate :seller, to: :listing
  belongs_to :buyer, class_name: 'Account'

  validates :listing_id, :buyer_id, :aasm_state, :amount, presence: true
  validates :amount, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ }
  validates :amount, numericality: {
    greater_than_or_equal_to: 1,
    less_than: 100_000_000
  }
  validate :buyer_cannot_be_seller

  aasm timestamps: true, no_direct_assignment: true do
    state :active, initial: true
    state :accepted, :paid, :rejected, :cancelled, :expired

    event :accept do
      transitions from: :active, to: :accepted, guards: %i[can_accept?]
      before do
        self.last_reminder_at = DateTime.now
      end
    end

    event :pay do
      transitions from: :accepted, to: :paid
    end

    event :reject do
      transitions from: :active, to: :rejected, guards: %i[can_accept?]
    end

    event :cancel do
      transitions from: :active, to: :cancelled, guards: %i[can_cancel?]
    end

    event :expire do
      transitions from: %i[active accepted], to: :expired
    end
  end

  scope :expired_active, lambda {
                           where('offers.aasm_state = ? AND offers.created_at < ?',
                                 :active, EXPIRY_TIME.ago)
                         }
  scope :expired_accepted, lambda {
                             where('offers.aasm_state = ? AND offers.accepted_at < ?',
                                   :accepted, EXPIRY_TIME.ago)
                           }
  scope :other_offers, lambda { |offer|
                         where('offers.listing_id = ? AND offers.buyer_id = ? AND offers.id != ?',
                               offer.listing_id, offer.buyer_id, offer.id)
                       }
  scope :accepted_or_paid, -> { where(aasm_state: %i[accepted paid]) }
  scope :one_day_reminder, lambda {
    where("(offers.aasm_state = 'active' AND offers.created_at < :time) OR " \
          "(offers.aasm_state = 'accepted' AND offers.accepted_at < :time)",
          time: ONE_DAY_BEFORE_EXPIRY.ago)
      .where('offers.last_reminder_at < ?', 1.day.ago)
  }
  scope :two_hour_reminder, lambda {
    where("(offers.aasm_state = 'active' AND offers.created_at < :time) OR " \
          "(offers.aasm_state = 'accepted' AND offers.accepted_at < :time)",
          time: TWO_HOURS_BEFORE_EXPIRY.ago)
      .where('offers.last_reminder_at < ?', 2.hours.ago)
  }

  before_create :set_last_reminder_at

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
    errors.add(:buyer, "buyer can't be the same as seller") if buyer_id == listing.account_id
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

  def send_reminder_email
    if active?
      counter ? OfferMailer.counter_offer_reminder(self).deliver : OfferMailer.offer_reminder(self).deliver
    elsif accepted?
      OfferMailer.offer_accepted_reminder(self).deliver
    end
  end

  private

  def can_accept?(account_id)
    (counter && account_id == buyer_id) || (!counter && account_id == seller.id)
  end

  def can_cancel?(account_id)
    (counter && account_id == seller.id) || (!counter && account_id == buyer_id)
  end

  def set_last_reminder_at
    self.last_reminder_at = DateTime.now
  end

  def send_active_reminder_email
    counter ? OfferMailer.counter_offer_reminder(self).deliver : OfferMailer.offer_reminder(self).deliver
  end
end
