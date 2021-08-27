# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "Skwirl <info@#{ENV['DOMAIN']}>"
  layout 'mailer'
end
