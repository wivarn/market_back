# frozen_string_literal: true

Jets.application.configure do
  config.gems.disable = false
  config.prewarm.enable = false
  config.cors = true

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  # TODO: Change this to use IAM or put secrets in SSM
  config.action_mailer.smtp_settings = {
    address: 'email-smtp.us-east-1.amazonaws.com',
    port: 587,
    authentication: :login,
    user_name: 'AKIAWPXJ4HVUTBUNL4M7',
    password: 'BB3U49Xz0953KbUhd43gAcrETqBNRh1edE+JFzJ+kLgQ',
    enable_starttls_auto: true
  }

  config.function.vpc_config = {
    security_group_ids: %w[sg-0ea722b0ee62aea2a],
    subnet_ids: %w[subnet-0ef4dcc378bce1fad subnet-05fae8cc3204c29d5 subnet-0b37866a3f88a58b7]
    # subnet_ids: %w[subnet-0acbe6648d2c3fbb0 subnet-0029d53651927eeb2 subnet-08f73460ec50bdb05]
  }

  # config.lambda.layers = [
  #   'arn:aws:lambda:us-east-1:446093344105:layer:rubylayer:1'
  # ]
end
