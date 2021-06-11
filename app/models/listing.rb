# frozen_string_literal: true

class Listing < ApplicationRecord
  validates :account, :photos, :title, :condition, :currency, :price, :domestic_shipping, :status, presence: true
  validates :title, length: { in: 2..256 }
  validates :description, length: { minimum: 5 }
  validates :status, inclusion: { in: %w[draft active removed pending_shipment shipped refunded] }

  validates :price, :domestic_shipping, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ }, allow_blank: false
  validates :price, numericality: {
    greater_than_or_equal_to: 0.25,
    less_than: 100_000_000
  }
  validates :domestic_shipping, numericality: {
    greater_than_or_equal_to: 0,
    less_than: 100_000_000
  }
  validates :international_shipping,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 100_000_000
            }, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ },
            allow_nil: true, allow_blank: false
  validates :currency, inclusion: { in: %w[USD CAD] }

  belongs_to :account
end
