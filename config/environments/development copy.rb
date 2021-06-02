# frozen_string_literal: true

require 'railgun/mailer'
# require 'railgun/message'

Jets.application.configure do
  config.gems.disable = true
  config.cors = true

  # config.action_mailer.some_test = 123
  # config.action_mailer.add_delivery_method = :ses, Aws::SES::Client
  config.action_mailer.delivery_method = :ses
  # config.action_mailer.file_settings = { location: Jets.root.join('tmp', 'mails') }
  # config.action_mailer.perform_deliveries = true

  ActiveRecord::Base.logger = Logger.new($stdout)
end

ActionMailer::Base.add_delivery_method :ses, Aws::SES::Client
# ActionMailer::Base.add_delivery_method :ses, :test
