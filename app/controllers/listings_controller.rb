# frozen_string_literal: true

class ListingsController < ApplicationController
  before_action :authenticate!, only: %i[index create bulk_create update delete]
  before_action :set_listing, only: %i[show]
  before_action :set_listing_through_account, only: %i[update delete]
  before_action :enforce_address_set!, only: %i[create update]

  def index
    scope = params[:status] || 'active'
    listings = current_account.listings.send(scope)
    listings = filter_and_sort(listings, params)

    render json: { listings: listings, total_pages: listings.total_pages }
  end

  def search
    listings = filter_and_sort(Listing.active, params)
    render json: { listings: listings, total_pages: listings.total_pages }
  end

  def show
    listing_with_name = @listing.serializable_hash.merge(@listing.account.slice(:given_name, :family_name))
    render json: listing_with_name
  end

  def create
    currency = current_account.currency
    country = current_account.addresses.first.country
    @listing = current_account.listings.new(listing_params.merge(currency: currency, shipping_country: country))

    if @listing.save
      render json: @listing, status: :created
    else
      render json: @listing.errors, status: :unprocessable_entity
    end
  end

  def bulk_create
    currency = current_account.currency
    country = current_account.addresses.first.country
    listings =
      current_account
      .listings
      .create_with(created_at: Time.now, updated_at: Time.now,
                   currency: currency, shipping_country: country, status: 'DRAFT')
      .insert_all(bulk_create_params[:listings])

    render json: listings, status: :created
  end

  def update
    if @listing.update(listing_params)
      render json: @listing
    else
      render json: @listing.errors, status: :unprocessable_entity
    end
  end

  def delete
    @listing.destroy
    render json: { deleted: true }
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def set_listing_through_account
    @listing = current_account.listings.find(params[:id])
  end

  def enforce_address_set!
    return unless current_account.addresses.none?

    render json: { error: 'address must be set before creating listings' }, status: :forbidden
  end

  def listing_params
    params.permit({ photos: [] }, :category, :subcategory, :title, :grading_company, :condition, :description, :price,
                  :domestic_shipping, :international_shipping, :status)
  end

  def bulk_create_params
    params.permit(listings: %i[category subcategory title grading_company condition description price
                               domestic_shipping international_shipping status])
  end

  def filter_and_sort(listings, params)
    listings = filter(listings, params)
    listings = sort(listings, params[:sort])

    listings.page(params[:page].to_i + 1)
  end

  def filter(listings, filters)
    listings = listings.where('title ilike :title', title: "%#{params[:title]}%") if filters[:title].present?
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
    listings = listings.where.not(grading_company: nil) if filters[:graded] == 'true'
    if filters[:grading_company].present?
      listings = listings.where('grading_company = :grading_company', grading_company: filters[:grading_company])
    end
    if filters[:min_condition].present?
      listings = listings.where('condition >= :condition', condition: filters[:min_condition])
    end
    listings
  end

  def filter_country(listings, filters)
    return listings unless filters[:shipping_country].present?

    listings.where('shipping_country = :country OR international_shipping IS NOT NULL',
                   country: filters[:shipping_country])
  end

  def sort(listings, order)
    case order
    when 'priceLow'
      listings.order(price: :asc)
    when 'priceHigh'
      listings.order(price: :desc)
    when 'priceShipLow'
      listings.select('*, (price + domestic_shipping) AS total_price').order(total_price: :asc)
    when 'priceShipHigh'
      listings.select('*, (price + domestic_shipping) AS total_price').order(total_price: :desc)
    when 'newest'
      listings.order(created_at: :asc)
    when 'oldest'
      listings.order(created_at: :desc)
    else
      listings
    end
  end
end
