# frozen_string_literal: true

class OrderBlueprint < Blueprinter::Base
  identifier :id
  fields :aasm_state, :total, :tracking, :created_at, :currency

  field :refunded_total do |order|
    order.refunds.inject(0) { |sum, refund| sum + refund.amount }
  end

  association :buyer, blueprint: AccountBlueprint
  association :seller, blueprint: AccountBlueprint
  association :address, blueprint: AddressBlueprint
  association :review, blueprint: ReviewBlueprint
  association :listings, blueprint: ListingBlueprint, view: :order do |order|
    destination = order.address.country
    listings = order.listings.to_a

    max_shipping_listing =
      listings.delete(listings.max_by { |listing| listing.shipping(destination_country: destination) })
    listings.each do |listing|
      listing.combined = true
      listing.destination_country = destination
    end
    [max_shipping_listing, *listings].compact
  end

  view :with_history do
    fields :pending_shipment_at, :shipped_at, :cancelled_at
    association :refunds, blueprint: RefundBlueprint
  end
end
