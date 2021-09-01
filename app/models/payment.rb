# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :account

  validates :account, presence: true
  validates :currency, inclusion: { in: %w[USD CAD] }, presence: true
end
