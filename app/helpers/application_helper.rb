# frozen_string_literal: true

module ApplicationHelper
  TOTAL_PRICE_SELECT = <<~QUERY
    *,
    (price +
      (CASE WHEN shipping_country = :destination_country
        THEN domestic_shipping
        ELSE international_shipping
      END)) AS total_price
  QUERY

  def sort_listings(listings, order, destination_country = 'USA')
    case order
    when 'priceLow'
      listings.reorder(price: :asc, id: :asc)
    when 'priceHigh'
      listings.reorder(price: :desc, id: :asc)
    when 'priceShipLow'
      listings.select(select_total_price(destination_country)).reorder(total_price: :asc, id: :asc)
    when 'priceShipHigh'
      listings.select(select_total_price(destination_country)).reorder(total_price: :desc, id: :asc)
    when 'newest'
      listings.reorder(updated_at: :desc, id: :asc)
    when 'oldest'
      listings.reorder(updated_at: :asc, id: :asc)
    else
      listings
    end
  end

  def select_total_price(destination_country = 'USA')
    ActiveRecord::Base.send(:sanitize_sql_array, [TOTAL_PRICE_SELECT, { destination_country: destination_country }])
  end
end
