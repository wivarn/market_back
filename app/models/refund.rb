# frozen_string_literal: true

class Refund < ApplicationRecord
  STRIPE_REASONS = %w[duplicate fraudulent requested_by_customer].freeze

  validates :order, :refund_id, :amount, :status, presence: true
  validate :reason, inclusion: { in: STRIPE_REASONS }, allow_nil: true
  validates :notes, presence: true, if: -> { !reason }

  belongs_to :order
end
