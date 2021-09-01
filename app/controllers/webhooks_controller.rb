# frozen_string_literal: true

class WebhooksController < ApplicationController
  before_action :filter_stripe_event, only: %i[stripe]
  def stripe
    order = Order.find @event.data.object.client_reference_id
    ActiveRecord::Base.transaction do
      order.pay!
      order.address = order.buyer.address.dup
      order.save
      Cart.destroy_by(buyer: order.buyer, seller: order.seller)
    end
    OrderMailer.pending_shipment(order).deliver
    OrderMailer.purchased(order).deliver

    render nothing: true, status: :no_content
  end

  private

  def filter_stripe_event
    @event = Stripe::Webhook.construct_event(request.body.read, headers['stripe-signature'],
                                             ENV['STRIPE_SIGNING_SECRET'])

    render nothing: true, status: :no_content unless @event.type == 'checkout.session.completed'
  rescue JSON::ParserError
    render json: { error: 'Invalid payload.' }, status: :bad_request
  rescue Stripe::SignatureVerificationError
    render json: { error: 'Invalid Signature.' }, status: :bad_request
  end
end
