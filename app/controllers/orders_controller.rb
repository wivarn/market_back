# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate!
  before_action :set_orders, only: %i[index]
  before_action :set_order, only: %i[update show update_state]
  before_action :set_order_and_review_through_buyer, only: %i[review]
  before_action :set_order_through_seller, only: %i[refund cancel]
  before_action :filter_orders_that_cannot_be_cancelled, only: %i[cancel]
  before_action :enforce_review_locked!, only: %i[review]
  before_action :enforce_review_editable!, only: %i[review]

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
      OrderMailer.cancelled(@order).deliver
      render json: OrderBlueprint.render(@order, view: :with_history)
    else
      render json: refund.errors, status: :unprocessable_entity
    end
  rescue Stripe::InvalidRequestError => e
    render json: { error: e.message }, status: e.http_status
  end

  def review
    @review.assign_attributes(params.compact.permit(:recommend, :feedback).merge(reviewer: 'BUYER'))
    if @review.save
      render json: OrderBlueprint.render(@order, view: :with_history)
    else
      render json: @review.errors, status: :unprocessable_entity
    end
  end

  private

  def set_orders
    relation = params[:relation] || params[:view]
    render json: { error: 'invalid view' }, status: 400 unless %w[purchases sales].include?(relation)

    @orders = current_account.public_send(relation).not_reserved.includes(:address, :buyer, :seller, :review,
                                                                          :refunds, listings: :accepted_offer)
  end

  def set_order
    render json: { error: 'invalid relation' }, status: 400 unless %w[purchases sales].include?(params[:relation])

    @order = current_account.public_send(params[:relation]).find(params[:id])
  end

  def set_order_and_review_through_buyer
    @order = current_account.purchases.find(params[:id])
    @review = Review.where(order: @order).first_or_initialize
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

  def enforce_review_locked!
    if @review.created_at&.<(14.days.ago) ||
       @order.cancelled_at&.<(14.days.ago) ||
       @order.refunds.order(:created_at).first&.created_at&.<(14.days.ago)
      render json: { error: 'Order review can no longer be updated' },
             status: :unprocessable_entity
    end
  end

  def enforce_review_editable!
    render json: { error: 'This order has not been paid yet' }, status: :unprocessable_entity if @order.reserved?

    return unless params[:feedback] && @review.recommend.nil?

    render json: { error: 'The recommend field must be set first' }, status: :unprocessable_entity
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
