# frozen_string_literal: true

class ApplicationController < Jets::Controller::Base
  private

  def rodauth
    request.env['rodauth']
  end

  def current_account
    response = catch(:halt) do
      @current_account ||= Account.find(rodauth.session_value)
    end
    @current_account || render(json: response[2][0], status: response[0])
  rescue ActiveRecord::RecordNotFound
    rodauth.logout
    render plain: 'you are not logged in'
  end
end
