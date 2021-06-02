# frozen_string_literal: true

# seems to be a dependancy for ActionMailer::Base.add_delivery_method to work
require 'railgun/mailer'

ActionMailer::Base.add_delivery_method :ses, Aws::SESV2::Client

module Aws
  module SESV2
    module ClientExtentions
      def deliver!(mail)
        response = send_email(
          from_email_address: mail.from.first,
          destination: {
            to_addresses: mail.destinations
          },
          content: {
            simple: {
              subject: {
                data: mail.subject,
                charset: 'UTF-8'
              },
              body: {
                text: {
                  data: mail.body.encoded,
                  charset: 'UTF-8'
                }
                # TODO: Enable when we have rich text emails
                # html: {
                #   data: mail.body.encoded
                #   # charset: 'UTF-8'
                # }
              }
            }
          }
        )

        response.message_id
      end

      def settings
        {}
      end
    end

    class Client
      prepend ClientExtentions
    end
  end
end
