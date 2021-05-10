# frozen_string_literal: true

class ListingsController < ApplicationController
  before_action :set_listing, only: %i[show update delete]
  before_action :current_account, only: %i[create update delete]

  # GET /listings
  def index
    @listings = Listing.all

    render json: @listings
  end

  # GET /listings/1
  def show
    render json: @listing
  end

  # POST /listings
  def create
    @listing = current_account.listings.new(listing_params)

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

  # Only allow a trusted parameter "white list" through.
  def listing_params
    params.required(:listing).permit({ photos: [] }, :title, :condition, :currency, :description, :price,
                                     :domestic_shipping, :status)
  end
end
