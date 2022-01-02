# frozen_string_literal: true

class OrderJob < ApplicationJob
  rate '1 day'
  def mark_received
    Order.pending_shipment.or(Order.shipped).where('orders.pending_shipment_at <= ?', 30.days.ago).find_each do |order|
      order.receive!(order.buyer_id)
      OrderMailer.received(order).deliver
    end
  end

  rate '1 day'
  def auto_review
    return if Jets.env.production?

    Order.left_joins(:review).where('reviews.id IS NULL AND orders.pending_shipment_at <= ?',
                                    30.days.ago).find_each do |order|
      order.create_review(recommend: true, feedback: nil, reviewer: 'SYSTEM')
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

  rate '1 day'
  def review_received
    Account.joins(sales: :review).where("reviews.reviewer != 'SYSTEM' AND reviews.updated_at > ?",
                                        1.day.ago).find_each do |account|
      OrderMailer.daily_review_received(account).deliver
    end
  end
end
