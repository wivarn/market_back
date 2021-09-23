# frozen_string_literal: true

class OrderJob < ApplicationJob
  rate '1 day'
  def mark_received
    Order.pending_shipment.or(Order.shipped).where('created_at <= ?', 30.days.ago).find_each do |order|
      order.receive!(order.buyer_id)
      OrderMailer.received(order).deliver
    end
  end
end
