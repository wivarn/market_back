# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :set_orders, only: %i[index]
  before_action :set_order, only: %i[update update_state]

  def index
    response = @orders.map do |order|
      order.serializable_hash(include: [:address, :listings, {
                                buyer: { only: %i[given_name family_name] },
                                seller: { only: %i[given_name family_name] }
                              }])
    end

    render json: response
  end

  def update
    if @order.seller_id != current_account.id
      render json: { error: 'Only the seller can update tracking' },
             status: :unauthorized
    elsif @order.update(order_params)
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def update_state
    unless %w[ship receive].include?(params[:state_transition])
      render json: { error: 'invalid state transition' },
             status: :bad_request
    end

    @order.aasm.fire(params[:state_transition], current_account.id)
    if @order.save
      render json: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private

  def set_orders
    render json: { error: 'invalid view' }, status: 400 unless %w[purchases sales].include?(params[:view])

    @orders = current_account.public_send(params[:view]).not_reserved.includes(:listings, :address, :buyer, :seller)
  end

  def set_order
    render json: { error: 'invalid relation' }, status: 400 unless %w[purchases sales].include?(params[:relation])

    @order = current_account.public_send(params[:relation]).find(params[:id])
  end

  def order_params
    params.permit(:tracking)
  end
end
