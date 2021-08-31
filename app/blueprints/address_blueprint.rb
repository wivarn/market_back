# frozen_string_literal: true

class AddressBlueprint < Blueprinter::Base
  COUNTRY_CODE_2 = {
    'CAN' => 'CA',
    'USA' => 'US'
  }.freeze

  fields :street1, :street2, :city, :state, :zip, :country

  view :location do
    excludes :street1, :street2, :city, :zip
  end

  view :for_stripe do
    excludes :street1, :street2, :zip
    field(:country) { |address| COUNTRY_CODE_2[address.country] }
    field :street1, name: :line1
    field :street2, name: :line2
    field :zip, name: :postal_code
  end
end
