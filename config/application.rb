require_relative '../app/racks/auth'

Jets.application.configure do
  config.project_name = 'market_back'
  config.mode = 'api'
  config.cors = true

  config.prewarm.enable = true
  config.prewarm.rate = '10 minutes'
  config.prewarm.concurrency = 1
  config.prewarm.public_ratio = 0

  config.function.timeout = 15 # defaults to 30
  config.function.memory_size = 512

  # must be set globally for rodauth
  config.iam_policy = [
    {
      action: ['ses:SendEmail'],
      effect: 'Allow',
      resource: "arn:aws:ses:#{Jets.aws.region}:#{Jets.aws.account}:identity/*"
    }
  ]
  config.middleware.use Auth

  config.function.vpc_config = {
    security_group_ids: [ENV['LAMBDA_SG_ID']],
    subnet_ids: ENV['PRIVATE_SUBNET_ID_LIST'].split(',')
  }

  config.domain.cert_arn = ENV['API_DOMAIN_CERT_ARN']
  config.domain.hosted_zone_name = ENV['DOMAIN']
  config.domain.name = "api.#{ENV['DOMAIN']}"
  # The config.function settings to the CloudFormation Lambda Function properties.
  # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-lambda-function.html
  # Underscored format can be used for keys to make it look more ruby-ish.

  # config.domain.endpoint_type = "EDGE"

  # By default logger needs to log to $stderr for CloudWatch to receive Lambda messages, but for
  # local testing environment you may want to log these messages to 'test.log' file to keep your
  # testing suite output readable.
  # config.logger = Jets::Logger.new($stderr)
  config.controllers.filtered_parameters += %i[password password-confirm]

  config.controllers.default_protect_from_forgery = false
end
