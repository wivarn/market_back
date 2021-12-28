# frozen_string_literal: true

class Review < ApplicationRecord
  belongs_to :order

  validates :order_id, :reviewer, presence: true
  validates :feedback, length: { maximum: 10_000 }, allow_blank: false, allow_nil: true
  validates :reviewer, inclusion: { in: %w[BUYER SYSTEM] }
end
