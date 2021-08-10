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
end
