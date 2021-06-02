# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'accounts@skwirl.io'
  layout 'mailer'
end
