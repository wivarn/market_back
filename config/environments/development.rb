# frozen_string_literal: true

Jets.application.configure do
  if ENV['AWS_ACCESS_KEY_ID']
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.delivery_method = :ses
  else
    config.action_mailer.delivery_method = :file
    config.action_mailer.file_settings = { location: Jets.root.join('tmp', 'mails') }
  end

  ActiveRecord::Base.logger = Logger.new($stdout)
end
