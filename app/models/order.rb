# frozen_string_literal: true

class Order < ApplicationRecord
  include AASM

  before_destroy :cancel_listing_reservations!, prepend: true

  belongs_to :buyer, class_name: 'Account'
  belongs_to :seller, class_name: 'Account'
  has_many :order_items, dependent: :destroy
  has_many :listings, through: :order_items
  has_many :refunds, dependent: :destroy
  has_one :address, as: :addressable, dependent: :destroy

  validates :buyer, :seller, :aasm_state, presence: true
  validates_length_of :order_items, maximum: 100

  validate :buyer_cannot_be_seller

  with_options if: -> { !reserved? } do |not_reserved|
    not_reserved.validates :total, :currency, presence: true
    not_reserved.validates :total, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ }
    not_reserved.validates :total, numericality: {
      greater_than_or_equal_to: 1,
      less_than: 100_000_000
    }
  end

  aasm timestamps: true, no_direct_assignment: true do
    state :reserved, initial: true
    state :pending_shipment, :shipped, :refunded, :received

    event :paid do
      transitions from: :reserved, to: :pending_shipment
    end

    event :ship do
      transitions from: :pending_shipment, to: :shipped, guard: :seller?
    end

    event :refund do
      transitions from: %i[pending_shipment shipped], to: :refunded
    end

    event :receive do
      transitions from: %i[pending_shipment shipped], to: :received, guard: :buyer?
    end
  end

  scope :not_reserved, -> { where('aasm_state != ?', :reserved) }

  def reserve!
    listings.each(&:reserve!)
  end

  def pay!(total, currency, payment_intent)
    self.total = total
    self.currency = currency
    self.payment_intent_id = payment_intent
    paid!
    listings.each(&:paid!)
  end

  private

  def cancel_listing_reservations!
    listings.reserved.each(&:cancel_reservation!)
  end

  def buyer_cannot_be_seller
    errors.add(:buyer_id, "buyer can't be the same as seller") if buyer_id == seller_id
  end

  def buyer?(account_id)
    account_id == buyer_id
  end

  def seller?(account_id)
    account_id == seller_id
  end
end
