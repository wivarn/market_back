# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :set_orders, only: %i[index]
  def index
    render json: @orders
  end

  def update; end

  private

  def set_orders
    render json: { error: 'invalid view' }, status: 400 unless %w[purchases sales].include?(params[:view])

    @orders = current_account.public_send(params[:view]).not_reserved.includes(:listings, :address, :seller)
  end
end
