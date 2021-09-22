# frozen_string_literal: true

class EmailSettingsController < ApplicationController
  before_action :authenticate!
  before_action :set_email_setting_through_account

  def show
    render json: EmailSettingBlueprint.render(@email_setting)
  end

  def update
    if @email_setting.update(email_setting_params)
      render json: EmailSettingBlueprint.render(@email_setting)
    else
      render json: @email_setting.errors, status: :unprocessable_entity
    end
  end

  private

  def set_email_setting_through_account
    @email_setting = EmailSetting.find_or_create_by(account: current_account)
  end

  def email_setting_params
    params.permit(:marketing)
  end
end
