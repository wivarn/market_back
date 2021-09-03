# frozen_string_literal: true

class OrderBlueprint < Blueprinter::Base
  identifier :id
  fields :aasm_state, :total, :tracking, :created_at
  association :buyer, blueprint: AccountBlueprint
  association :seller, blueprint: AccountBlueprint
  association :address, blueprint: AddressBlueprint
  association :listings, blueprint: ListingBlueprint do |order|
    listings = order.listings.to_a
    listings.each { |listing| listing.destination_country = order.address.country }
    listings
  end
end
