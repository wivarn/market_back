# frozen_string_literal: true

class ApplicationController < Jets::Controller::Base
  private

  def rodauth
    request.env['rodauth']
  end

  def current_account
    @current_account ||= Account.find(rodauth.session_value)
  rescue ActiveRecord::RecordNotFound
    rodauth.logout
    rodauth.login_required
  end
end
