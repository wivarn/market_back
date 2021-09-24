# frozen_string_literal: true

class BackfillOrdersJob < ApplicationJob
  def fill
    Payment.pluck(:stripe_id).compact.each do |stripe_id|
      Stripe::Checkout::Session.list({ limit: 100 }, { stripe_account: stripe_id }).each do |session|
        if session.payment_status == 'paid' && session.payment_intent && session.client_reference_id
          Order.where(id: session.client_reference_id).update_all(payment_intent_id: session.payment_intent)
        end
      end
    rescue Stripe::PermissionError
      puts "skipping #{stripe_id}"
    end
  end
end
