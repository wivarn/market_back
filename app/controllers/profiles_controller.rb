# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate!
  before_action :ensure_key_present!, only: [:update_picture_key]

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

  def upload_picture_credentials
    current_account.picture = nil
    uploader = current_account.picture
    uploader.key = nil
    uploader.success_action_redirect = "#{ENV['FRONT_END_BASE_URL']}/account/profile"
    render json: uploader.direct_fog_hash.merge(success_action_redirect: uploader.success_action_redirect)
  end

  iam_policy({
               action: ['s3:PutObject', 's3:PutObjectAcl'],
               effect: 'allow',
               resource: "#{ENV['PUBLIC_ASSETS_BUCKET_ARN']}/uploads/account/picture/*"
             })
  def presigned_put_url
    render json: ImageUploader.new(current_account, 'picture').presigned_put_url(params[:filename])
  end

  iam_policy({
               action: ['s3:DeleteObject'],
               effect: 'allow',
               resource: "#{ENV['PUBLIC_ASSETS_BUCKET_ARN']}/uploads/account/picture/*"
             })
  def update_picture_key
    old_key = current_account.picture.key
    current_account.update_column(:picture, params[:key])
    current_account.reload
    if current_account.valid?
      current_account.picture.remove_from_s3(old_key)
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
      listing_template: ListingTemplate.find_or_create_by(account: current_account)
    }
  end

  private

  def account_params
    params.permit(:given_name, :family_name, :currency, :picture)
  end

  def stripe_linked?
    stripe_connection = StripeConnection.where(account: current_account).first_or_initialize
    if stripe_connection.stripe_account
      Stripe::Account.retrieve(stripe_connection.stripe_account).charges_enabled
    else
      false
    end
  rescue Stripe::PermissionError
    false
  end

  def ensure_key_present!
    render json: { error: '"key" is a required param' }, status: :unprocessable_entity unless params[:key]
  end
end
