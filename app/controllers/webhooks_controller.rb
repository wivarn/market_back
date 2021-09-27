# frozen_string_literal: true

class WebhooksController < ApplicationController
  before_action :set_stripe_event, only: %i[stripe]
  before_action :filter_stripe_event, only: %i[stripe]

  VALID_EVENTS = %w[checkout.session.completed checkout.session.expired charge.refund.updated].freeze

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
    render json: { error: 'event type not accepted' } unless VALID_EVENTS.include?(@event.type)
  end

  def find_order
    Order.find @event.data.object.client_reference_id
  end

  def checkout_session_completed
    ActiveRecord::Base.transaction do
      order = find_order
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

  def charge_refund_updated
    stripe_refund = @event.data.object
    refund = Refund.find_by_refund_id(stripe_refund.id).update(amount: stripe_refund.amount / 100.0,
                                                               status: stripe_refund.status)
    return unless refund.status == 'failed'

    OrderMailer.refund_failed_seller(refund).deliver
    OrderMailer.refund_failed_buyer(refund).deliver
  end
end
