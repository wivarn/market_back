# frozen_string_literal: true

class ListingBlueprint < ApplicationBlueprint
  fields :photos, :title, :grading_company, :condition, :currency, :price, :aasm_state

  # fields :photos, :category, :subcategory, :tags, :title, :grading_company, :condition, :description, :currency,
  #        :price, :combined_shipping, :shipping_country, :aasm_state, :reserved_at

  view :preview do
    field :shipping do |listing, options|
      destination_country = options[:destination_country] || 'USA'
      if destination_country == listing.shipping_country
        listing.domestic_shipping
      else
        listing.international_shipping
      end
    end
  end

  view :seller do
    fields :domestic_shipping, :international_shipping, :combined_shipping
  end

  view :buyer do
    # association :account, name: :seller, blueprint: AccountBlueprint
  end
end
