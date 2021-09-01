# frozen_string_literal: true

class Cart < ApplicationRecord
  belongs_to :buyer, class_name: 'Account'
  belongs_to :seller, class_name: 'Account'
  has_many :cart_items, dependent: :destroy
  has_many :listings, through: :cart_items, dependent: :destroy

  validates_length_of :cart_items, maximum: 100
  validate :buyer_cannot_be_seller
  validates_uniqueness_of :buyer, scope: :seller

  def buyer_cannot_be_seller
    errors.add(:buyer, "buyer can't be the same as seller") if buyer_id == seller_id
  end
end
