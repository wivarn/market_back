# frozen_string_literal: true

require 'roda'
require 'sequel'
require 'bcrypt'
require 'rotp'
require 'rqrcode'

class Auth < Roda
  DB = Sequel.connect('postgresql://', extensions: :activerecord_connection)

  plugin :middleware

  plugin :rodauth, json: :only do
    enable :create_account, :verify_account, :close_account, :internal_request,
           :login, :logout, :active_sessions,
           :jwt, :jwt_cors, :jwt_refresh,
           :reset_password, :change_password, :update_password_hash, :change_password_notify,
           :disallow_password_reuse, :password_complexity, :disallow_common_passwords,
           :change_login, :verify_login_change,
           :otp, :recovery_codes, :lockout,
           :audit_logging, :password_pepper

    # base config
    use_database_authentication_functions? false
    set_deadline_values? true
    hmac_secret ENV['HMAC_SECRET']
    base_url ENV['FRONT_END_BASE_URL']

    # login/email config
    require_login_confirmation? false
    verify_account_set_password? false
    change_login_requires_password? true

    # account verification config
    account_status_column :status
    account_unverified_status_value 'unverified'
    account_open_status_value 'verified'
    account_closed_status_value 'closed'
    verify_account_skip_resend_email_within 60

    # close account config
    delete_account_on_close? false

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
    password_hash_cost 12
    password_pepper ENV['PASSWORD_PEPPER']
    change_password_requires_password? true
    reset_password_skip_resend_email_within 1.minute
    reset_password_autologin? true

    # jwt config
    jwt_secret ENV['JWT_SECRET']
    jwt_cors_allow_origin true
    expired_jwt_access_token_status 401
    jwt_access_token_period 30.minutes
    allow_refresh_with_expired_jwt_access_token? true

    # session config
    session_inactivity_deadline 14.days
    session_lifetime_deadline nil

    # account lockout
    max_invalid_logins 5

    # email configs
    create_verify_account_email do
      RodauthMailer.verify_account(email_to, "#{account_id}#{token_separator}#{compute_hmac(verify_account_key_value)}")
    end
    create_reset_password_email do
      RodauthMailer.reset_password(email_to, "#{account_id}#{token_separator}#{compute_hmac(reset_password_key_value)}")
    end
    create_verify_login_change_email do |login|
      RodauthMailer.verify_login_change(login, verify_login_change_old_login, verify_login_change_new_login,
                                        "#{account_id}#{token_separator}#{compute_hmac(verify_login_change_key_value)}")
    end
    create_password_changed_email do
      RodauthMailer.password_changed(email_to)
    end
    create_unlock_account_email do
      RodauthMailer.unlock_account(email_to, "#{account_id}#{token_separator}#{compute_hmac(get_unlock_account_key)}")
    end
  end

  route do |r|
    env['rodauth'] = rodauth
    r.rodauth
    rodauth.check_active_session
  end
end
