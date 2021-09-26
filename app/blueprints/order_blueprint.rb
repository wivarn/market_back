# frozen_string_literal: true

class OrderBlueprint < Blueprinter::Base
  identifier :id
  fields :aasm_state, :total, :tracking, :created_at, :currency
  association :buyer, blueprint: AccountBlueprint
  association :seller, blueprint: AccountBlueprint
  association :address, blueprint: AddressBlueprint
  association :listings, blueprint: ListingBlueprint do |order|
    listings = order.listings.to_a
    listings.each { |listing| listing.destination_country = order.address.country }
    listings
  end

  view :with_history do
    fields :paid_at, :shipped_at, :refunded_at, :received_at
  end
end
