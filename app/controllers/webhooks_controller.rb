# frozen_string_literal: true

class WebhooksController < ApplicationController
  before_action :set_stripe_event, only: %i[stripe]
  before_action :filter_stripe_event, only: %i[stripe]

  VALID_EVENTS = %w[checkout.session.completed checkout.session.expired charge.refunded charge.refund.updated].freeze

  def stripe
    send(@event.type.gsub('.', '_'))

    render nothing: true, status: :no_content
  end

  private

  def set_stripe_event
    @event = Stripe::Webhook.construct_event(request.body.read, headers['stripe-signature'],
                                             ENV['STRIPE_SIGNING_SECRET'])
  rescue JSON::ParserError
    render json: { error: 'Invalid payload.' }, status: :bad_request
  rescue Stripe::SignatureVerificationError
    render json: { error: 'Invalid Signature.' }, status: :bad_request
  end

  def filter_stripe_event
    if !VALID_EVENTS.include?(@event.type)
      render json: { error: 'event type not accepted' }
    elsif @event.data.object.respond_to?(:success_url) && !@event.data.object.success_url.start_with?(ENV['FRONT_END_BASE_URL'])
      render nothing: true, status: :no_content
    end
  end

  def find_order
    Order.find @event.data.object.client_reference_id
  end

  def checkout_session_completed
    order = find_order
    ActiveRecord::Base.transaction do
      session = @event.data.object
      order.pay!(session.amount_total / 100.0, session.currency.upcase, session.payment_intent)
      Cart.destroy_by(buyer: order.buyer, seller: order.seller)
    end
    OrderMailer.pending_shipment(order).deliver
    OrderMailer.purchased(order).deliver
  end

  def checkout_session_expired
    find_order.destroy
  end

  # this catches cases when sellers manually refund via Stripe
  def charge_refunded
    stripe_refund = @event.data.object.refunds.data.first
    order = Order.find_by_payment_intent_id(stripe_refund.payment_intent)
    refund = Refund.find_or_create_by(order: order, refund_id: stripe_refund.id)

    refund.update(amount: stripe_refund.amount / 100.0,
                  status: stripe_refund.status,
                  reason: stripe_refund.reason)
  end

  def charge_refund_updated
    stripe_refund = @event.data.object
    refund = Refund.find_by_refund_id(stripe_refund.id)
    return unless refund

    refund.update(amount: stripe_refund.amount / 100.0,
                  status: stripe_refund.status)
    return unless refund.status == 'failed'

    OrderMailer.refund_failed_seller(refund).deliver
    OrderMailer.refund_failed_buyer(refund).deliver
  end
end
