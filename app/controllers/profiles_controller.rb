# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate!
  before_action :ensure_identifier_present!, only: [:update_picture_identifier]

  def show
    render json: AccountBlueprint.render(current_account, view: :full)
  end

  def update
    current_account.update(account_params)

    if current_account.save
      render json: AccountBlueprint.render(current_account, view: :full)
    else
      render json: current_account.errors, status: :unprocessable_entity
    end
  end

  iam_policy({
               action: ['s3:PutObject', 's3:PutObjectAcl'],
               effect: 'Allow',
               resource: "#{ENV['PUBLIC_ASSETS_BUCKET_ARN']}/uploads/account/picture/*"
             })
  def presigned_put_url
    render json: ImageUploader.new(current_account, 'picture').presigned_put_url(params[:filename])
  end

  iam_policy({
               action: ['s3:DeleteObject'],
               effect: 'Allow',
               resource: "#{ENV['PUBLIC_ASSETS_BUCKET_ARN']}/uploads/account/picture/*"
             })
  def update_picture_identifier
    current_account.write_attribute(:picture, params[:identifier])
    if current_account.save
      render json: current_account
    else
      render json: current_account.errors, status: :unprocessable_entity
    end
  end

  def settings
    render json: {
      currency: current_account.currency,
      country: current_account.address&.country || 'USA',
      address_set: !current_account.address.nil?,
      stripe_linked: stripe_linked?,
      listing_template: ListingTemplate.find_or_create_by(account: current_account),
      has_cart: current_account.carts.any?,
      has_pending_shipment: current_account.sales.pending_shipment.any?,
      selling_enabled: current_account.seller?
    }
  end

  private

  def account_params
    params.permit(:given_name, :family_name, :currency, :picture)
  end

  def stripe_linked?
    payment = Payment.where(account: current_account).first_or_initialize
    if payment.stripe_id
      Stripe::Account.retrieve(payment.stripe_id).charges_enabled
    else
      false
    end
  rescue Stripe::PermissionError
    false
  end

  def ensure_identifier_present!
    render json: { error: '"identifier" is a required param' }, status: :unprocessable_entity unless params[:identifier]
  end
end
