# frozen_string_literal: true

class CartsController < ApplicationController
  before_action :authenticate!
  def show
    cart = Cart.where(account: current_account).first_or_initialize

    render json: cart
  end

  # def update
  #   address = if current_account.addresses.any?
  #               current_account.addresses.first
  #             else
  #               current_account.addresses.new
  #             end

  #   if address.update(address_params)
  #     render json: address
  #   else
  #     render json: address.errors, status: :unprocessable_entity
  #   end
  # end
end
