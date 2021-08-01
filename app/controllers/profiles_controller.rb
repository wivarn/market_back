# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate!
  def show
    render json: current_account
  end

  def update
    current_account.update(account_params)

    if current_account.save
      render json: current_account
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

  def update_picture_key
    current_account.picture = nil
    current_account.picture.key = params['key']
    if current_account.save
      render json: current_account
    else
      render json: current_account.errors, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.permit(:given_name, :family_name, :currency, :picture)
  end
end
