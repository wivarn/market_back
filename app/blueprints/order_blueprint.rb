# frozen_string_literal: true

class OrderBlueprint < Blueprinter::Base
  identifier :id
  fields :aasm_state, :total, :tracking, :created_at, :currency
  association :buyer, blueprint: AccountBlueprint
  association :seller, blueprint: AccountBlueprint
  association :address, blueprint: AddressBlueprint
  association :refunds, blueprint: RefundBlueprint
  association :listings, blueprint: ListingBlueprint do |order|
    listings = order.listings.to_a
    listings.each { |listing| listing.destination_country = order.address.country }
    listings
  end

  view :with_history do
    fields :pending_shipment_at, :shipped_at, :received_at, :cancelled_at
  end
end
