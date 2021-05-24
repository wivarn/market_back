# frozen_string_literal: true

Jets.application.configure do
  config.gems.disable = true
  config.cors = true

  config.action_mailer.delivery_method = :file
  config.action_mailer.file_settings = { location: Jets.root.join('tmp', 'mails') }
  config.action_mailer.perform_deliveries = true

  ActiveRecord::Base.logger = Logger.new($stdout)
end
