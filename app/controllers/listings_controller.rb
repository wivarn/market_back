# frozen_string_literal: true

class ListingsController < ApplicationController
  before_action :authenticate!, only: %i[index create update delete]
  before_action :set_listing, only: %i[show]
  before_action :set_listing_through_account, only: %i[update delete]
  before_action :enforce_address_set!, only: %i[create update]
  before_action :search_params, only: %i[search]

  # GET /listings
  def index
    if params[:status]
      render json: current_account.listings.send(params[:status])
    else
      render json: current_account.listings.active
    end
  end

  def search
    render json: [] unless search_params[:title]

    query = Listing.active.where('title ilike :title', title: "%#{search_params[:title]}%")
    query = query.where('price >= :gt', gt: search_params[:gt]) if search_params[:gt]
    query = query.where('price <= :lt', lt: search_params[:lt]) if search_params[:lt]
    query = query..where('category = :category', category: search_params[:category]) if search_params[:category]
    if search_params[:subcategory]
      query = query.where('subcategory = :subcategory',
                          subcategory: search_params[:subcategory])
    end
    if search_params[:grading_company]
      query = query.where('grading_company = :grading_company',
                          grading_company: search_params[:grading_company])
    end
    query = query.where('condition IN :condition', condition: search_params[:condition]) if search_params[:condition]

    render json: query
  end

  # GET /listings/1
  def show
    listing_with_name = @listing.serializable_hash.merge(@listing.account.slice(:given_name, :family_name))
    render json: listing_with_name
  end

  # POST /listings
  def create
    @listing = current_account.listings.new(listing_params.merge(currency: current_account.currency))

    if @listing.save
      render json: @listing, status: :created
    else
      render json: @listing.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /listings/1
  def update
    if @listing.update(listing_params)
      render json: @listing
    else
      render json: @listing.errors, status: :unprocessable_entity
    end
  end

  # DELETE /listings/1
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

  def search_params
    params.permit(:title, :gt, :lt, :category, :subcategory, :grading_company, :condition)
  end
end
