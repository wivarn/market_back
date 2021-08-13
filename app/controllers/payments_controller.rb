# frozen_string_literal: true

class PaymentsController < ApplicationController
  COUNTRY_CODE_2 = {
    'CAD' => 'CA',
    'USA' => 'US'
  }.freeze

  before_action :authenticate!
  before_action :enforce_address_set!

  def show
    if stripe_connection.stripe_account
      render json: { id: Stripe::Account.retrieve(stripe_connection.stripe_account).id }
    else
      render json: {}, status: :no_content
    end
  rescue Stripe::PermissionError => e
    stripe_connection.destroy
    if e.code == 'account_invalid'
      render json: { error: 'Account not found. Stripe connection may have been revoked' },
             status: :not_found
    end
  end

  def link_account
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

  def address
    @address ||= current_account.address
  end

  def stripe_connection
    @stripe_connection ||= StripeConnection.where(account: current_account).first_or_initialize
  end

  def stripe_account
    @stripe_account ||= create_or_load_stripe_account
  end

  def create_or_load_stripe_account
    if stripe_connection.stripe_account
      Stripe::Account.retrieve(stripe_connection.stripe_account)
    else
      stripe_account = create_stripe_account
      stripe_connection.update(stripe_account: stripe_account.id)
      stripe_account
    end
  end

  def create_stripe_account
    Stripe::Account.create(
      type: 'standard', email: current_account.email,
      default_currency: current_account.currency.downcase,
      country: COUNTRY_CODE_2[address.country],
      business_type: 'individual',
      company: { address: map_stripe_address },
      individual: map_stripe_individual
    )
  end

  def map_stripe_address
    {
      country: COUNTRY_CODE_2[address.country],
      city: address.city,
      line1: address.street1,
      line2: address.street2,
      postal_code: address.zip,
      state: address.state
    }
  end

  def map_stripe_individual
    {
      email: current_account.email,
      first_name: current_account.given_name,
      last_name: current_account.family_name
    }
  end

  def enforce_address_set!
    return if current_account.address

    render json: { error: 'Address must be set before linking Stripe account' }, status: :forbidden
  end
end
