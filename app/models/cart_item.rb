# frozen_string_literal: true

class CartItem < ApplicationRecord
  belongs_to :cart, dependent: :destroy
  belongs_to :listing, dependent: :destroy

  validates_uniqueness_of :listing, scope: :cart
end
