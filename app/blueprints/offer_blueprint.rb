# frozen_string_literal: true

class OfferBlueprint < Blueprinter::Base
  identifier :id
  fields :amount, :expires_at, :counter
  association :buyer, blueprint: AccountBlueprint
  association :seller, blueprint: AccountBlueprint
  association :listing, blueprint: ListingBlueprint
end
