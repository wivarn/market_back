# frozen_string_literal: true

Jets.application.configure do
  # config.gems.disable = false
  # config.gems.disable = true
  config.prewarm.enable = false

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :ses

  # config.lambda.layers = [
  #   'arn:aws:lambda:us-east-1:446093344105:layer:rubylayer:10'
  # ]
end
