Jets.application.configure do
  config.gems.disable = true
  config.cors = true

  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
end
