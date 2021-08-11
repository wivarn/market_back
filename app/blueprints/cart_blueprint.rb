# frozen_string_literal: true

class CartBlueprint < ApplicationBlueprint
  association :seller, blueprint: AccountBlueprint
  association :listings, blueprint: ListingBlueprint, view: :preview do |cart, options|
    destination = options[:destination_country]
    listings = cart.listings.to_a
    max_shipping_listing =
      listings.delete(listings.max_by { |listing| listing.shipping(destination_country: destination) })
    listings.each { |listing| listing.combined = true }
    [max_shipping_listing] + listings
  end

  field :total do |cart, options|
    destination = options[:destination_country]
    listings = cart.listings.to_a
    max_shipping_listing =
      listings.delete(listings.max_by { |listing| listing.shipping(destination_country: destination) })

    total_shipping = listings.inject(max_shipping_listing.shipping(destination_country: destination)) do |sum, listing|
      sum + listing.shipping(destination_country: destination, combined: true)
    end
    total_listing_price = listings.inject(max_shipping_listing.price) { |sum, listing| sum + listing.price }

    total_shipping + total_listing_price
  end
end
