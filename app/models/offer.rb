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

  aasm timestamps: true, no_direct_assignment: true do
    state :active, initial: true
    state :accepted, :rejected, :cancelled

    event :accept do
      transitions from: :active, to: :accepted, guards: %i[active? seller?]
    end

    event :reject do
      transitions from: :active, to: :rejected, guards: %i[active? seller?]
    end

    event :cancel do
      transitions from: :active, to: :cancelled, guards: %i[active? buyer?]
    end
  end

  scope :active, -> { where('offers.aasm_state = ? AND offers.created_at >= ?', :active, DateTime.now - EXPIRY_TIME) }
  scope :expired, -> { where('offers.aasm_state = ? AND offers.created_at < ?', :active, DateTime.now - EXPIRY_TIME) }

  def active?
    aasm_state == 'active' && (created_at >= DateTime.now - EXPIRY_TIME)
  end

  def expired?
    aasm_state == 'active' && (created_at < DateTime.now - EXPIRY_TIME)
  end

  def expires_at
    created_at + EXPIRY_TIME
  end

  private

  def seller?(account_id)
    account_id == seller.id
  end

  def buyer?(account_id)
    account_id == buyer_id
  end
end
