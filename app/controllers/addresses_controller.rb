# frozen_string_literal: true

class AddressesController < ApplicationController
  before_action :authenticate!
  def show
    render json: current_account.addresses
  end

  def update
    address = if current_account.addresses.any?
                current_account.addresses.first
              else
                current_account.addresses.new
              end

    if address.update(address_params)
      render json: address
    else
      render json: address.errors, status: :unprocessable_entity
    end
  end

  private

  def address_params
    params.permit(:street1, :street2, :city, :state, :zip, :country)
  end
end
