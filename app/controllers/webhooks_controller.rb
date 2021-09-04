# frozen_string_literal: true

class WebhooksController < ApplicationController
  before_action :set_stripe_event, only: %i[stripe]
  before_action :filter_stripe_event, only: %i[stripe]
  before_action :set_order, only: %i[stripe]

  VALID_EVENTS = %w[checkout.session.completed checkout.session.expired].freeze

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
    elsif !@event.data.object.success_url.start_with?(ENV['FRONT_END_BASE_URL'])
      render nothing: true, status: :no_content
    end
  end

  def set_order
    @order = Order.find @event.data.object.client_reference_id
  end

  def checkout_session_completed
    ActiveRecord::Base.transaction do
      @order.pay!(@event.data.object.amount_total / 100.0, @event.data.object.currency.upcase)
      Cart.destroy_by(buyer: @order.buyer, seller: @order.seller)
    end
    OrderMailer.pending_shipment(@order).deliver
    OrderMailer.purchased(@order).deliver
  end

  def checkout_session_expired
    @order.destroy
  end
end
