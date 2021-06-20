# frozen_string_literal: true

class ListingsController < ApplicationController
  before_action :authenticate!, only: %i[index create update delete]
  before_action :set_listing, only: %i[show]
  before_action :set_listing_through_account, only: %i[update delete]
  before_action :enforce_address_set!, only: %i[create update]

  def index
    scope = params[:status] || 'active'
    listings = current_account.listings.send(scope).page(params[:page].to_i + 1)

    render json: { listings: listings, total_pages: listings.total_pages }
  end

  def search
    query = Listing.active.where('title ilike :title', title: "%#{params[:title]}%")
    query = query.where('price >= :min_price', min_price: params[:min_price]) if params[:min_price].present?
    query = query.where('price <= :max_price', max_price: params[:max_price]) if params[:max_price].present?
    query = query.where('category = :category', category: params[:category]) if params[:category].present?
    if params[:subcategory].present?
      query = query.where('subcategory = :subcategory',
                          subcategory: params[:subcategory])
    end
    if params[:grading_company].present?
      query = query.where('grading_company = :grading_company',
                          grading_company: params[:grading_company])
    end
    query = query.where('condition >= :condition', condition: params[:min_condition]) if params[:min_condition].present?

    if params[:sort].present?
      query = query.order(price: :asc) if params[:sort] == 'priceLow'
      query = query.order(price: :desc) if params[:sort] == 'priceHigh'
      if params[:sort] == 'priceShipLow'
        query = query.select('*, (price + domestic_shipping) AS total_price').order(total_price: :asc)
      end
      if params[:sort] == 'priceShipHigh'
        query = query.select('*, (price + domestic_shipping) AS total_price').order(total_price: :desc)
      end
      query = query.order(created_at: :asc) if params[:sort] == 'newest'
      query = query.order(created_at: :desc) if params[:sort] == 'oldest'
    end

    query = query.page(params[:page].to_i + 1)
    render json: { listings: query, total_pages: query.total_pages }
  end

  def show
    listing_with_name = @listing.serializable_hash.merge(@listing.account.slice(:given_name, :family_name))
    render json: listing_with_name
  end

  def create
    @listing = current_account.listings.new(listing_params.merge(currency: current_account.currency))

    if @listing.save
      render json: @listing, status: :created
    else
      render json: @listing.errors, status: :unprocessable_entity
    end
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
end
