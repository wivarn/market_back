# frozen_string_literal: true

Jets.application.configure do
  config.gems.disable = true
  config.cors = true

  config.action_mailer.raise_delivery_errors = true
  # config.action_mailer.delivery_method = :file
  # config.action_mailer.file_settings = { location: Jets.root.join('tmp', 'mails') }
  # config.action_mailer.perform_deliveries = true

  # TODO: Change this to use IAM or put secrets in SSM
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'email-smtp.us-east-1.amazonaws.com',
    port: 587,
    authentication: :login,
    user_name: 'AKIAWPXJ4HVUTBUNL4M7',
    password: 'BB3U49Xz0953KbUhd43gAcrETqBNRh1edE+JFzJ+kLgQ',
    enable_starttls_auto: true
  }

  ActiveRecord::Base.logger = Logger.new($stdout)
end
