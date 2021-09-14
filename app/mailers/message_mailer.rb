# frozen_string_literal: true

class MessageMailer < ApplicationMailer
  default from: "Skwirl <messages@#{ENV['DOMAIN']}>"

  def received(message)
    recipient = message.recipient.email
    @sender_full_name = message.sender.full_name
    @body = message.body
    @reply_link = "#{ENV['FRONT_END_BASE_URL']}/messages/#{message.sender_id}"

    mail to: recipient, subject: 'You have a new message'
  end
end
