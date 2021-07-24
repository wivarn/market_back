# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :account
  belongs_to :seller, class_name: 'Account'
  has_many :order_items, dependent: :destroy
  has_many :listings, through: :order_items, dependent: :destroy

  validates :account, :seller, :aasm_state, :total, presence: true
  validates_length_of :order_items, maximum: 100

  validates :total, format: { with: /\A\d{1,8}(\.\d{0,2})?\z/ }
  validates :total, numericality: {
    greater_than_or_equal_to: 1,
    less_than: 100_000_000
  }
  validate :buyer_cannot_be_seller

  def buyer_cannot_be_seller
    errors.add(:account, "buyer can't be the same as seller") if account_id == seller_id
  end
end
