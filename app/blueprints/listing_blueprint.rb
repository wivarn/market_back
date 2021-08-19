# frozen_string_literal: true

class ListingBlueprint < ApplicationBlueprint
  fields :photos, :title, :grading_company, :condition, :currency, :price, :aasm_state
  field :shipping do |listing, options|
    listing.shipping(destination_country: options[:destination_country], combined: options[:combined])
  end

  view :seller do
    fields :category, :subcategory, :tags, :description, :domestic_shipping, :international_shipping,
           :combined_shipping, :shipping_country, :reserved_at
  end

  view :buyer do
    fields :description, :category, :subcategory, :combined_shipping
    association :account, name: :seller, blueprint: AccountBlueprint, view: :with_location
  end
end
