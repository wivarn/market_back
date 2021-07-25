# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :set_orders, only: %i[index]
  def index
    response = @orders.map do |order|
      order.serializable_hash(include: [:address, :listings, {
                                buyer: { only: %i[given_name family_name] },
                                seller: { only: %i[given_name family_name] }
                              }])
    end

    render json: response
  end

  def update; end

  private

  def set_orders
    render json: { error: 'invalid view' }, status: 400 unless %w[purchases sales].include?(params[:view])

    @orders = current_account.public_send(params[:view]).not_reserved.includes(:listings, :address, :buyer, :seller)
  end
end
