# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  default from: "Skwirl <orders@#{ENV['DOMAIN']}>"

  def purchased(order)
    recipient = order.buyer.email
    @purchases_link = "#{ENV['FRONT_END_BASE_URL']}/account/purchases/#{order.id}"

    mail to: recipient, subject: 'You made a purchase'
  end

  def pending_shipment(order)
    recipient = order.seller.email
    @sales_link = "#{ENV['FRONT_END_BASE_URL']}/account/sales/#{order.id}"

    mail to: recipient, subject: 'You sold some items'
  end

  def shipped(order)
    recipient = order.buyer.email
    @purchases_link = "#{ENV['FRONT_END_BASE_URL']}/account/purchases"

    mail to: recipient, subject: 'Your order has shipped'
  end

  def received(order)
    recipient = order.seller.email
    @sales_link = "#{ENV['FRONT_END_BASE_URL']}/account/sales"

    mail to: recipient, subject: 'Your shipment was received'
  end

  def refunded(order)
    recipient = order.buyer.email

    @order_link = "#{ENV['FRONT_END_BASE_URL']}/account/purchases/#{order.id}"

    mail to: recipient, subject: 'Your order has been refunded'
  end

  def refund_failed_seller(refund)
    order = refund.order
    recipient = order.seller.email

    @order_link = "#{ENV['FRONT_END_BASE_URL']}/account/sales/#{order.id}"

    mail to: recipient, subject: 'Your refund has failed'
  end

  def refund_failed_buyer(refund)
    order = refund.order
    recipient = order.buyer.email

    @order_link = "#{ENV['FRONT_END_BASE_URL']}/account/purchases/#{order.id}"

    mail to: recipient, subject: 'Your refund has failed'
  end

  def cancelled(order)
    recipient = order.buyer.email

    @order_link = "#{ENV['FRONT_END_BASE_URL']}/account/purchases/#{order.id}"

    mail to: recipient, subject: 'Your order has been cancelled'
  end

  def review_reminder(order)
    recipient = order.buyer.email

    @order_link = "#{ENV['FRONT_END_BASE_URL']}/account/purchases/#{order.id}"

    mail to: recipient, subject: 'Please provide feedback on your purchase'
  end

  def daily_review_received(account)
    recipient = account.email

    orders = account.sales.joins(:review).where("reviews.reviewer != 'SYSTEM' AND reviews.updated_at > ?", 1.day.ago)
    @order_links = orders.map { |order| "#{ENV['FRONT_END_BASE_URL']}/account/purchases/#{order.id}" }.join("\n")

    mail to: recipient, subject: 'You have received some feedback'
  end
end
