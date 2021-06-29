# frozen_string_literal: true

class StripeConnection < ApplicationRecord
  belongs_to :account
end
