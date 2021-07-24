# frozen_string_literal: true

class Cart < ApplicationRecord
  belongs_to :account, dependent: :destroy
  belongs_to :seller, class_name: 'Account', dependent: :destroy
  has_many :cart_items
  has_many :listings, through: :cart_items

  validates_length_of :cart_items, maximum: 100
  validate :buyer_cannot_be_seller

  def buyer_cannot_be_seller
    errors.add(:account, "buyer can't be the same as seller") if account_id == seller_id
  end
end
