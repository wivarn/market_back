# frozen_string_literal: true

class PaymentsController < ApplicationController
  before_action :authenticate!

  def show
    stripe_connection = current_account.stripe_connection
    if stripe_connection
      render json: Stripe::Account.retrieve(stripe_connection.stripe_account)
    else
      render json: {}, status: :no_content
    end
  end

  def link_account
    stripe_account = create_load_stripe_account

    if stripe_account.charges_enabled
      render json: { error: 'You already have a linked Stripe Account' }, status: :conflict
    else
      account_link = Stripe::AccountLink.create(
        type: 'account_onboarding',
        account: stripe_account.id,
        refresh_url: "#{ENV['FRONT_END_BASE_URL']}/account/payments",
        return_url: "#{ENV['FRONT_END_BASE_URL']}/account/payments"
      )

      render json: { url: account_link.url }
    end
  end

  private

  def create_load_stripe_account
    stripe_connection = StripeConnection.where(account: current_account).first_or_initialize
    if stripe_connection.stripe_account
      Stripe::Account.retrieve(stripe_connection.stripe_account)
    else
      stripe_account = Stripe::Account.create(type: 'standard', email: current_account.email)
      stripe_connection.update(stripe_account: stripe_account.id)
      stripe_account
    end
  end
end
