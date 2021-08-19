# frozen_string_literal: true

class AccountBlueprint < Blueprinter::Base
  identifier :id
  field :picture
  field :full_name do |account|
    "#{account.given_name} #{account.family_name}"
  end

  view :with_location do
    association :address, blueprint: AddressBlueprint, view: :location
  end

  view :full do
    excludes :full_name
    fields :email, :status, :given_name, :family_name, :currency, :role
  end

  view :with_recent_listings do
    include_view :with_location
    association :listings, blueprint: ListingBlueprint do |account, options|
      account.listings.active.ships_to(options[:destination_country] || 'USA').order(created_at: :desc).limit(4)
    end
  end
end
