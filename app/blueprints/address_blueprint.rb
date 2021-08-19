# frozen_string_literal: true

class AddressBlueprint < ApplicationBlueprint
  fields :street1, :street2, :city, :state, :zip, :country

  view :location do
    excludes :street1, :street2, :city, :zip
  end
end
