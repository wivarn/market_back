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

  private

  def account_params
    params.permit(:given_name, :family_name, :currency, :picture)
  end
end
