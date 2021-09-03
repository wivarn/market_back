# frozen_string_literal: true

class ListingBlueprint < Blueprinter::Base
  identifier :id
  fields :photos, :title, :grading_company, :condition, :currency, :price
  field :aasm_state do |listing|
    listing.aasm_state == 'reserved' && listing.active? ? 'active' : listing.aasm_state
  end
  field :shipping do |listing, options|
    listing.shipping(destination_country: options[:destination_country], combined: options[:combined])
  end

  view :seller do
    fields :category, :subcategory, :tags, :description, :domestic_shipping, :international_shipping,
           :combined_shipping, :shipping_country, :reserved_at
  end

  view :buyer do
    fields :description, :category, :subcategory, :combined_shipping, :reserved_at
    association :account, name: :seller, blueprint: AccountBlueprint, view: :with_location
  end
end
