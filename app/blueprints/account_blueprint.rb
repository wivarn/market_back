# frozen_string_literal: true

class AccountBlueprint < ApplicationBlueprint
  excludes :updated_at, :created_at

  field :picture
  field :full_name do |account|
    "#{account.given_name} #{account.family_name}"
  end

  view :full do
    excludes :full_name, :updated_at, :created_at
    fields :email, :status, :given_name, :family_name, :currency, :role
  end

  view :with_recent_listings do
    excludes :updated_at, :created_at
    association :listings, blueprint: ListingBlueprint, view: :preview do |account, options|
      account.listings.active.ships_to(options[:ships_to] || 'USA').order(created_at: :desc).limit(4)
    end
  end
end
