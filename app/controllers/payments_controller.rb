# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :authenticate!

  def show
    render json: current_account.stripe_connection || {}
  end

  def link_account
    stripe_account = Stripe::Account.create(type: 'standard')
    current_account.create_stripe_connection(stripe_account: stripe_account.id)

    account_link = Stripe::AccountLink.create(
      type: 'account_onboarding',
      account: stripe_account.id,
      refresh_url: "#{ENV['FRONT_END_BASE_URL']}/account/payments",
      return_url: "#{ENV['FRONT_END_BASE_URL']}/account/payments"
    )

    render json: { url: account_link.url }
  end

  # def link_account_refresh; end
end
