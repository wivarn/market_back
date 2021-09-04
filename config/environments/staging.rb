# frozen_string_literal: true

Jets.application.configure do
  config.prewarm.enable = false

  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :ses
end
