# frozen_string_literal: true

class EmailSettingsController < ApplicationController
  before_action :authenticate!
  before_action :set_email_setting_through_account

  def show
    render json: EmailSettingBlueprint.render(@email_setting)
  end

  def update
    old_mailchimp = @email_setting.marketing

    begin
      if @email_setting.update(email_setting_params)
        update_mailchimp if old_mailchimp != @email_setting.marketing
        render json: EmailSettingBlueprint.render(@email_setting)
      else
        render json: @email_setting.errors, status: :unprocessable_entity
      end
    rescue MailchimpMarketing::ApiError
      @email_setting.update(marketing: !@email_setting.marketing)
      render json: { error: 'Unable to update marketing email settings' }, status: :unprocessable_entity
    end
  end

  private

  def set_email_setting_through_account
    @email_setting = EmailSetting.find_or_create_by(account: current_account)
  end

  def email_setting_params
    params.permit(:marketing)
  end

  def update_mailchimp
    return unless ENV['MAILCHIMP_API_KEY']

    subscriber_hash = Digest::MD5.hexdigest current_account.email.downcase
    status = @email_setting.marketing ? 'subscribed' : 'unsubscribed'

    mailchimp_client.lists.set_list_member ENV['MAILCHIMP_AUDIENCE_ID'], subscriber_hash,
                                           { email_address: current_account.email,
                                             status: status,
                                             email_type: 'html',
                                             merge_fields: mailchimp_merge_fields }
  end

  def mailchimp_client
    @mailchimp_client ||= MailchimpMarketing::Client.new(api_key: ENV['MAILCHIMP_API_KEY'],
                                                         server: ENV['MAILCHIMP_API_SERVER'])
  end

  def mailchimp_merge_fields
    {
      FNAME: current_account.given_name,
      LNAME: current_account.family_name
    }
  end
end
