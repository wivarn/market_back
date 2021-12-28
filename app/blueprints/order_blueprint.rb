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
    listings = order.listings.to_a
    listings.each { |listing| listing.destination_country = order.address.country }
    listings
  end

  view :with_history do
    fields :pending_shipment_at, :shipped_at, :cancelled_at
    association :refunds, blueprint: RefundBlueprint
  end
end
