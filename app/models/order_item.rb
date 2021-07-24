# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :listing

  validates_uniqueness_of :listing, scope: :order

  validates :order, :listing, :shipping, presence: true
  validates :shipping, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ }
  validates :shipping, numericality: {
    greater_than_or_equal_to: 1,
    less_than: 100_000_000
  }
end
