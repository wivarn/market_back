# frozen_string_literal: true

class RodauthMailer < ApplicationMailer
  default from: "Skwirl <accounts@#{ENV['DOMAIN']}>"

  def verify_account(recipient, key)
    @email_link = "#{ENV['FRONT_END_BASE_URL']}/auth/verifyAccount?key=#{key}"

    mail to: recipient, subject: 'Verify your account'
  end

  def reset_password(recipient, key)
    @email_link = "#{ENV['FRONT_END_BASE_URL']}/auth/resetPassword?key=#{key}"

    mail to: recipient, subject: 'Reset your password'
  end

  def verify_login_change(recipient, old_login, new_login, key)
    @old_login  = old_login
    @new_login  = new_login
    @email_link = "#{ENV['FRONT_END_BASE_URL']}/auth/verifyAccountChange?key=#{key}"

    mail to: recipient, subject: 'Verify email change'
  end

  def password_changed(recipient)
    mail to: recipient, subject: 'Your password has been changed'
  end

  # def email_auth(recipient, email_link)
  #   @email_link = email_link
  #
  #   mail to: recipient
  # end

  def unlock_account(recipient, key)
    @email_link = "#{ENV['FRONT_END_BASE_URL']}/auth/unlockAccount?key=#{key}"

    mail to: recipient
  end
end
