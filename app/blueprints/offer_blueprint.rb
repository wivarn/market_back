# frozen_string_literal: true

class OfferBlueprint < Blueprinter::Base
  identifier :id
  field :amount
  association :buyer, blueprint: AccountBlueprint
end
