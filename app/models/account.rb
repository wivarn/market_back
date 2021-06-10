# frozen_string_literal: true

class Account < ApplicationRecord
  has_many :listings
  has_many :addresses

  validates :currency, inclusion: { in: %w[USD CAD] }, presence: true
end
