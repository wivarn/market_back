# frozen_string_literal: true

class CartBlueprint < Blueprinter::Base
  association :seller, blueprint: AccountBlueprint
  association :listings, blueprint: ListingBlueprint do |cart, options|
    destination = options[:destination_country]
    listings = cart.listings.to_a

    max_shipping_listing =
      listings.delete(listings.max_by { |listing| listing.shipping(destination_country: destination) })
    listings.each { |listing| listing.combined = true }
    [max_shipping_listing, *listings].compact
  end

  field :total do |cart, options|
    destination = options[:destination_country]
    listings = cart.listings.to_a

    if listings.empty?
      0
    else
      max_shipping_listing =
        listings.delete(listings.max_by { |listing| listing.shipping(destination_country: destination) })
      total_shipping = listings.inject(max_shipping_listing.shipping(destination_country: destination)) do |sum, listing|
        sum + listing.shipping(destination_country: destination, combined: true)
      end
      total_listing_price = listings.inject(max_shipping_listing.price) { |sum, listing| sum + listing.price }

      total_shipping + total_listing_price
    end
  end
end
