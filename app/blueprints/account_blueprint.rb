# frozen_string_literal: true

class AccountBlueprint < Blueprinter::Base
  identifier :id
  field :picture
  field :full_name do |account|
    "#{account.given_name} #{account.family_name}"
  end

  view :with_location do
    fields :total_sales_with_feedback, :recommendation_rate
    association :address, blueprint: AddressBlueprint, view: :location
  end

  view :full do
    excludes :full_name
    fields :email, :status, :given_name, :family_name, :role
  end

  view :with_recent_listings do
    include_view :with_location
    association :listings, blueprint: ListingBlueprint do |account, options|
      account.listings.active.ships_to(options[:destination_country]).order(updated_at: :desc, id: :asc).limit(4)
    end
  end

  view :stripe_shipping do
    excludes :id, :picture, :full_name
    field :name do |account|
      "#{account.given_name} #{account.family_name}"
    end
    association :address, blueprint: AddressBlueprint, view: :for_stripe
  end

  view :admin do
    excludes :picture, :full_name
    fields :email, :status, :given_name, :family_name, :role, :fee
  end
end
