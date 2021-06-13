# frozen_string_literal: true

class ListingsController < ApplicationController
  before_action :set_listing, only: %i[show]
  before_action :authenticate!, only: %i[index create update delete]
  before_action :set_listing_through_account, only: %i[update delete]

  # GET /listings
  def index
    if params[:status]
      render json: current_account.listings.send(params[:status])
    else
      render json: current_account.listings.active
    end
  end

  def search
    render json: Listing.active
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

  # Use callbacks to share common setup or constraints between actions.
  def set_listing
    @listing = Listing.find(params[:id])
  end

  def set_listing_through_account
    @listing = current_account.listings.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def listing_params
    params.permit({ photos: [] }, :category, :subcategory, :title, :condition, :description, :price,
                  :domestic_shipping, :status)
  end
end
