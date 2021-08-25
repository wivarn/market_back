# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  default from: "orders@#{ENV['DOMAIN']}"
  
  def purchased(order)
    recipient = order.buyer.email
    @purchases_link = "#{ENV['FRONT_END_BASE_URL']}/account/purchases"

    mail to: recipient, subject: "You bought something"
  end

  def pending_shipment(order)
    recipient = order.seller.email
    @sales_link = "#{ENV['FRONT_END_BASE_URL']}/account/sales"

    mail to: recipient, subject: "You sold something"
  end

  def shipped(order)
    recipient = order.buyer.email
    @purchases_link = "#{ENV['FRONT_END_BASE_URL']}/account/purchases"

    mail to: recipient, subject: "Your order has shipped"
  end

  def received(order)
    recipient = order.seller.email
    @sales_link = "#{ENV['FRONT_END_BASE_URL']}/account/sales"

    mail to: recipient, subject: "Your shipment was received"
  end
end
