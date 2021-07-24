# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :set_orders, only: %i[index]
  def index
    render json: @orders
  end

  def show; end

  def update; end

  private

  def set_orders
    @orders = if params[:view] == 'purchases'
                current_account.purchases.not_reserved
              else
                current_account.sales.not_reserved
              end
  end
end
