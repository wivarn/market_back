# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "info@#{ENV['DOMAIN']}"
  layout 'mailer'
end
