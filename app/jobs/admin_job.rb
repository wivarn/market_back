# frozen_string_literal: true

class AdminJob < ApplicationJob
  def make_admin
    account = Account.find_by_email(event['email'])
    account.update_attribute(:role, 'admin')
  end
end
