# frozen_string_literal: true

class AdminJob < ApplicationJob
  def make_admin
    account = Account.find_by_email(event['email'])
    account.update_attribute(:role, 'admin')
  end

  def close_account
    Auth.rodauth.close_account(account_login: event['email'])
  end
end
