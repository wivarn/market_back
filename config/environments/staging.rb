# frozen_string_literal: true

Jets.application.configure do
  config.gems.disable = false
  config.prewarm.enable = false

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :ses

  config.function.vpc_config = {
    security_group_ids: %w[sg-0c7dfee716adf3909],
    subnet_ids: %w[subnet-091bf49612a0f7abe subnet-091bf49612a0f7abe subnet-0e47637bd652c39ce]
  }

  config.domain.cert_arn = 'arn:aws:acm:us-west-2:112233445577:certificate/8d8919ce-a710-4050-976b-b33da991e7e8' # String
  config.domain.hosted_zone_name = 'coolapp.com'

  # config.lambda.layers = [
  #   'arn:aws:lambda:us-east-1:446093344105:layer:rubylayer:1'
  # ]
end
