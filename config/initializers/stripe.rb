# frozen_string_literal: true

Stripe.api_key = ENV['STRIPE_SECRET_KEY']
Stripe.log_level = Stripe::LEVEL_INFO
