# frozen_string_literal: true

require 'roda'
require 'sequel'
require 'bcrypt'

class Auth < Roda
  DB = Sequel.connect('postgresql://', extensions: :activerecord_connection)

  plugin :middleware
  # plugin :json
  # plugin :json_parser

  plugin :rodauth, json: :only do
    enable :create_account,
           :login, :logout, :jwt,
           :reset_password, :change_password,
           :change_login, :jwt_refresh, :remember

    # enable :create_account, :verify_account, :verify_account_grace_period,
    #        :login, :logout, :jwt,
    #        :reset_password, :change_password, :change_password_notify,
    #        :change_login, :verify_login_change

    # login/email config
    require_login_confirmation? false

    # custom account fields
    before_create_account do
      unless given_name = param_or_nil('given_name')
        throw_error_status(422, 'given_name', 'must be present')
      end

      unless family_name = param_or_nil('family_name')
        throw_error_status(422, 'family_name', 'must be present')
      end

      account[:given_name] = given_name
      account[:family_name] = family_name
    end

    # password config
    use_database_authentication_functions? false
    password_minimum_length 8

    # account verification config
    account_status_column :status
    account_unverified_status_value 'unverified'
    account_open_status_value 'verified'
    # account_closed_status_value 'closed'

    # jwt config
    jwt_secret '657e57e5784301eeab3dcbfef181d6b86d5c97eb3dd2770ee89f1b656248311c068e45a46e796d254be3cbacfaa96da60426696c99a68d4d5a3978a2b6d4b2d3'
    expired_jwt_access_token_status 401
    jwt_access_token_period 900

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

    # remember cookie configu
    after_login do
      remember_login
    end
  end

  route do |r|
    env['rodauth'] = rodauth
    r.rodauth
  end
end
