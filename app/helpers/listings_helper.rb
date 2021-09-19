# frozen_string_literal: true

module ListingsHelper
  TOTAL_PRICE_SELECT = <<~QUERY
    *,
    (price +
      (CASE WHEN shipping_country = :destination_country
        THEN domestic_shipping
        ELSE international_shipping
      END)) AS total_price
  QUERY

  private

  def filter_and_sort(listings, params)
    listings = filter(listings, params)
    listings = sort_listings(listings, params[:sort])

    listings.page(params[:page].to_i + 1)
  end

  def filter(listings, filters)
    listings = listings.search(filters[:query]) if filters[:query].present?
    listings = filter_price(listings, filters)
    listings = filter_category(listings, filters)
    listings = filter_condition(listings, filters)
    filter_country(listings, filters)
  end

  def filter_price(listings, filters)
    listings = listings.where('price >= :min_price', min_price: filters[:min_price]) if filters[:min_price].present?
    listings = listings.where('price <= :max_price', max_price: filters[:max_price]) if filters[:max_price].present?
    listings
  end

  def filter_category(listings, filters)
    listings = listings.where('category = :category', category: filters[:category]) if filters[:category].present?
    if filters[:subcategory].present?
      listings = listings.where('subcategory = :subcategory', subcategory: filters[:subcategory])
    end
    listings
  end

  def filter_condition(listings, filters)
    listings = listings.where.not(grading_company: '') if filters[:graded] == 'true'
    if filters[:grading_company].present?
      listings = listings.where('grading_company = :grading_company', grading_company: filters[:grading_company])
    end
    if filters[:min_condition].present?
      listings = listings.where('condition >= :condition', condition: filters[:min_condition])
    end
    listings
  end

  def filter_country(listings, filters)
    listings = listings.ships_to(filters[:destination_country]) if filters[:destination_country].present?
    listings = listings.where(shipping_country: filters[:shipping_country]) if filters[:shipping_country].present?
    listings
  end

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
