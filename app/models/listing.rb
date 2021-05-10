# frozen_string_literal: true

class Listing < ApplicationRecord
  validates :account, :photos, :title, :condition, :currency, :price, :domestic_shipping, :status, presence: true
  validates :title, length: { in: 2..100 }
  validates :price, :domestic_shipping, :international_shipping,
            format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ },
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 100_000_000
            },
            allow_nil: true

  belongs_to :account
end
