# frozen_string_literal: true

class AddressesController < ApplicationController
  before_action :authenticate!

  def show
    render json: AddressBlueprint.render(current_account.address || {})
  end

  def update
    address = Address.where(addressable: current_account).first_or_initialize

    if address.update(address_params)
      render json: AddressBlueprint.render(address)
    else
      render json: address.errors, status: :unprocessable_entity
    end
  end

  private

  def address_params
    params.permit(:street1, :street2, :city, :state, :zip, :country)
  end
end
