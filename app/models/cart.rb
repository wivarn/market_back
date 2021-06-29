# frozen_string_literal: true

class Cart < ApplicationRecord
  belongs_to :account
  has_many :cart_items
  has_many :listings, through: :cart_items
end
