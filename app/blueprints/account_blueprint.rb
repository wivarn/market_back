# frozen_string_literal: true

class AccountBlueprint < ApplicationBlueprint
  excludes :updated_at, :created_at

  field :picture
  field :full_name do |account|
    "#{account.given_name} #{account.family_name}"
  end
end
