# frozen_string_literal: true

class ListingTemplatesController < ApplicationController
  before_action :authenticate!
  before_action :set_listing_template

  def show
    render json: @listing_template
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

  def set_listing_template
    @listing_template = ListingTemplate.find_or_create_by(account: current_account)
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
                  :domestic_shipping, :status)
  end

  def search_params
    params.permit(:category, :title, :currency, :price, :status)
  end
end
