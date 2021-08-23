# frozen_string_literal: true

if defined?(MailSafe::Config)
  MailSafe::Config.internal_address_definition = lambda { |address|
    address =~ /.*@skwirl\.io/i || address =~ /.*@mailinator\.com/i
  }
  MailSafe::Config.replacement_address = 'staging-mailsafe@skwirl.io'
end
