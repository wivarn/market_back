# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  default from: "orders@#{ENV['DOMAIN']}"

  def pending_shipment(order)
    recipient = order.seller.email
    @sales_link = "#{ENV['FRONT_END_BASE_URL']}/account/sales"

    mail to: recipient
  end

  def shipped(order)
    recipient = order.buyer.email
    @purchases_link = "#{ENV['FRONT_END_BASE_URL']}/account/purchases"

    mail to: recipient
  end

  def received(order)
    recipient = order.seller.email
    @sales_link = "#{ENV['FRONT_END_BASE_URL']}/account/sales"

    mail to: recipient
  end
end
