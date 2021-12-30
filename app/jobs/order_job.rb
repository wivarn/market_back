# frozen_string_literal: true

class OrderJob < ApplicationJob
  rate '1 day'
  def mark_received
    Order.pending_shipment.or(Order.shipped).where('created_at <= ?', 30.days.ago).find_each do |order|
      order.receive!(order.buyer_id)
      order.create_review(recommend: true, feedback: nil, reviewer: 'SYSTEM') unless order.review
      OrderMailer.received(order).deliver
    end
  end

  rate '1 day'
  def review_reminder
    Order.left_joins(:review).where(
      'reviews.id IS NULL AND orders.pending_shipment_at <= ? AND orders.pending_shipment_at > ?',
      14.days.ago, 15.days.ago
    ).find_each do |order|
      OrderMailer.review_reminder(order).deliver
    end
  end
end
