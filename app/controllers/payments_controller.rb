# frozen_string_literal: true

class PaymentsController < ApplicationController
  DEFAULT_STRIPE_SETTINGS = {
    card_payments: { statement_descriptor_prefix: 'SKWIRL' },
    payments: { statement_descriptor: 'SKWIRL.IO' }
  }.freeze

  COUNTRY_CODE_2 = {
    'CAN' => 'CA',
    'USA' => 'US'
  }.freeze

  before_action :authenticate!
  before_action :enforce_address_set!
  before_action :enforce_seller!, only: %i[link_account]

  def show
    if payment.stripe_id
      render json: { stripe_id: Stripe::Account.retrieve(payment.stripe_id).id, currency: payment.currency }
    else
      render json: { currency: payment.currency }
    end
  rescue Stripe::PermissionError => e
    payment.destroy
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
  rescue Stripe::InvalidRequestError => e
    render json: { error: e.message }, status: e.http_status
  end

  def update_currency
    if payment.update(currency: params[:currency])
      render json: payment.slice(:currency)
    else
      render json: payment.errors, status: :unprocessable_entity
    end
  end

  private

  def address
    @address ||= current_account.address
  end

  def payment
    @payment ||= Payment.where(account: current_account).first_or_create
  end

  def stripe_account
    @stripe_account ||= create_or_load_stripe_account
  end

  def create_or_load_stripe_account
    if payment.stripe_id
      Stripe::Account.retrieve(payment.stripe_id)
    else
      stripe_account = create_stripe_account
      payment.update(stripe_id: stripe_account.id)
      stripe_account
    end
  end

  def create_stripe_account
    Stripe::Account.create(
      type: 'standard', email: current_account.email,
      default_currency: payment.currency.downcase,
      country: COUNTRY_CODE_2[address.country],
      business_type: 'individual',
      company: map_stripe_address,
      business_profile: map_business_profile,
      individual: map_stripe_individual,
      settings: DEFAULT_STRIPE_SETTINGS
    )
  end

  def map_stripe_address
    {
      address: AddressBlueprint.render_as_hash(address, view: :for_stripe)
    }
  end

  def map_business_profile
    {
      # mcc is merchant category code. 5399 is 'Miscellaneous General Merchandise'.
      mcc: '5399',
      url: Jets.env.development? ? 'https://skwirlhouse1.ca' : ENV['FRONT_END_BASE_URL'],
      name: "#{current_account.given_name}'s Skwirl Store",
      product_description: 'Sports cards, trading cards and collectibles'
      # support_phone: TODO
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

  def enforce_seller!
    return if current_account.seller?

    render json: { error: 'Selling has not been enabled for you' }, status: :forbidden
  end
end
