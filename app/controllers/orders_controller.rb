# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :set_orders, only: %i[index]
  before_action :set_order, only: %i[update show update_state]
  before_action :set_order_through_buyer, only: %i[feedback]
  before_action :set_order_through_seller, only: %i[refund cancel]
  before_action :filter_orders_that_cannot_be_cancelled, only: %i[cancel]
  before_action :enforce_feedback_editable!, only: %i[feedback]

  def index
    paginated_orders = @orders.order(created_at: :desc).page(params[:page].to_i).per(10)
    render json: OrderBlueprint.render(paginated_orders, root: :orders,
                                                         meta: { total_pages: paginated_orders.total_pages })
  end

  def show
    render json: OrderBlueprint.render(@order, view: :with_history)
  end

  def update
    if @order.seller_id != current_account.id
      render json: { error: 'Only the seller can update tracking' },
             status: :unauthorized
    elsif @order.update(order_params)
      render json: OrderBlueprint.render(@order)
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
      send_email
      render json: OrderBlueprint.render(@order, view: :with_history)
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  def refund
    unless %w[pending_shipment shipped].include?(@order.aasm_state)
      render json: { error: "This order can't be refunded" },
             status: :unprocessable_entity
    end

    refund = create_stripe_refund((params[:amount].to_f * 100).to_i)

    if refund.save
      OrderMailer.refunded(@order).deliver
      render json: OrderBlueprint.render(@order, view: :with_history)
    else
      render json: refund.errors, status: :unprocessable_entity
    end
  rescue Stripe::InvalidRequestError => e
    render json: { error: e.message }, status: e.http_status
  end

  def cancel
    refund = create_stripe_refund
    if refund.save
      @order.cancel!(current_account.id)
      OrderMailer.cancalled(@order).deliver
      render json: OrderBlueprint.render(@order, view: :with_history)
    else
      render json: refund.errors, status: :unprocessable_entity
    end
  rescue Stripe::InvalidRequestError => e
    render json: { error: e.message }, status: e.http_status
  end

  def feedback
    @order.assign_attributes(params.permit(:recommend, :feedback))
    @order.feedback_at = DateTime.now unless @order.feedback_at
    if @order.save
      render json: OrderBlueprint.render(@order, view: :with_history)
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private

  def set_orders
    relation = params[:relation] || params[:view]
    render json: { error: 'invalid view' }, status: 400 unless %w[purchases sales].include?(relation)

    @orders = current_account.public_send(relation).not_reserved.includes(:address, :buyer, :seller,
                                                                          :refunds, listings: :accepted_offer)
  end

  def set_order
    render json: { error: 'invalid relation' }, status: 400 unless %w[purchases sales].include?(params[:relation])

    @order = current_account.public_send(params[:relation]).find(params[:id])
  end

  def set_order_through_buyer
    @order = current_account.purchases.find(params[:id])
  end

  def set_order_through_seller
    @order = current_account.sales.find(params[:id])
  end

  def filter_orders_that_cannot_be_cancelled
    unless @order.pending_shipment?
      render json: { error: "Only orders that haven't been shipped can be cancelled" },
             status: :unprocessable_entity
    end

    if @order.refunds.any?
      render json: { error: "Partially refunded orders can't be cancelled" },
             status: :unprocessable_entity
    end
  end

  def enforce_feedback_editable!
    if @order.feedback_at && @order.feedback_at < 30.days.ago
      render json: { error: 'Order feedback cannot be updated after 30 days' },
             status: :unprocessable_entity
    end

    return if %w[shipped received].include?(@order.aasm_state)

    render json: { error: 'You cannot give feedback until the order has been shipped' }, status: :unprocessable_entity
  end

  def send_email
    case params[:state_transition]
    when 'ship'
      OrderMailer.shipped(@order).deliver
    when 'receive'
      OrderMailer.received(@order).deliver
    end
  end

  def order_params
    params.permit(:tracking)
  end

  def create_stripe_refund(amount = nil)
    refund_params = { payment_intent: @order.payment_intent_id,
                      amount: amount,
                      reason: params[:reason].presence,
                      refund_application_fee: true }
    stripe_refund = Stripe::Refund.create(refund_params, { stripe_account: @order.seller.payment.stripe_id })

    @order.refunds.new(refund_id: stripe_refund.id,
                       amount: stripe_refund.amount / 100.0,
                       status: stripe_refund.status,
                       reason: stripe_refund.reason || '',
                       notes: params[:notes])
  end
end
