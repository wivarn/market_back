# frozen_string_literal: true

class OrderBlueprint < ApplicationBlueprint
  fields :aasm_state, :total, :tracking
  association :buyer, blueprint: AccountBlueprint
  association :seller, blueprint: AccountBlueprint
  association :address, blueprint: AddressBlueprint
  association :listings, blueprint: ListingBlueprint
end
