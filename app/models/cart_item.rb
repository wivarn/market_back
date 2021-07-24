# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :listing

  validates_uniqueness_of :listing, scope: :cart
end
