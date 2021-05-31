# frozen_string_literal: true

require 'roda'
require 'sequel'
require 'bcrypt'

class Auth < Roda
  DB = Sequel.connect('postgresql://', extensions: :activerecord_connection)

  plugin :middleware

  plugin :rodauth, json: :only do
    enable :create_account,
           :login, :logout, :jwt, :active_sessions,
           :reset_password, :change_password, :update_password_hash,
           :change_login, :jwt_refresh, :password_pepper

    # enable :verify_account, :verify_account_grace_period,
    #        :change_password_notify

    # TODO: :two_factor, :audit_logging, :otp, :recovery_codes
    # Maybe? :change_login, :verify_login_change, :close_account, :disallow_password_reuse
    # :email_auth, :lockout, :password_complexity, :password_expiration, :sms_codes

    # Not required
    # session_expiration because we're using jwt/jwt refresh

    hmac_secret ENV['HMAC_SECRET']
    password_pepper ENV['PASSWORD_PEPPER']

    # login/email config
    require_login_confirmation? false

    # custom account fields
    before_create_account do
      unless (given_name = param_or_nil('given_name'))
        throw_error_status(422, 'given_name', 'must be present')
      end

      unless (family_name = param_or_nil('family_name'))
        throw_error_status(422, 'family_name', 'must be present')
      end

      account[:given_name] = given_name
      account[:family_name] = family_name
    end

    # password config
    use_database_authentication_functions? false
    password_minimum_length 8
    password_hash_cost 12

    # account verification config
    account_status_column :status
    account_unverified_status_value 'unverified'
    account_open_status_value 'verified'
    # account_closed_status_value 'closed'

    # jwt config
    jwt_secret ENV['JWT_SECRET']
    expired_jwt_access_token_status 401
    jwt_access_token_period 1800 # 30 min
    allow_refresh_with_expired_jwt_access_token? true

    # verify_account_set_password? false

    # create_reset_password_email do
    #   RodauthMailer.reset_password(email_to, reset_password_email_link)
    # end
    # create_verify_account_email do
    #   RodauthMailer.verify_account(email_to, verify_account_email_link)
    # end
    # create_verify_login_change_email do |login|
    #   RodauthMailer.verify_login_change(login, verify_login_change_old_login, verify_login_change_new_login,
    #                                     verify_login_change_email_link)
    # end
    # create_password_changed_email do
    #   RodauthMailer.password_changed(email_to)
    # end
  end

  route do |r|
    env['rodauth'] = rodauth
    r.rodauth
    rodauth.check_active_session
  end
end
