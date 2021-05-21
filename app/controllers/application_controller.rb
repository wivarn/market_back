# frozen_string_literal: true

class ApplicationController < Jets::Controller::Base
  private

  def rodauth
    request.env['rodauth']
  end

  def authenticate!
    response = catch(:halt) do
      load_session
      @current_account = Account.find(rodauth.session_value)
    end
    # response is in format: [status, headers, [body]]
    @current_account || render(json: response[2][0], status: response[0])
  rescue ActiveRecord::RecordNotFound
    rodauth.logout
    render json: { error: 'you are not logged in' }, status: 401
  end

  def load_session
    return if rodauth.valid_jwt?

    rodauth.load_memory
    rodauth.session_value && response.add_header('Authorization', rodauth.session_jwt)
  end

  def current_account
    raise 'session has not been authenticated' unless defined?(@current_account)

    @current_account
  end
end
