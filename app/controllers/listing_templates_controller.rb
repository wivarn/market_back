# frozen_string_literal: true

class ListingTemplatesController < ApplicationController
  before_action :authenticate!
  before_action :set_listing_template
  before_action :listing_template_params, only: [:update]

  def show
    render json: @listing_template
  end

  # PATCH/PUT /listings/1
  def update
    if @listing_template.update(listing_template_params)
      render json: @listing_template
    else
      render json: @listing_template.errors, status: :unprocessable_entity
    end
  end

  # DELETE /listings/1
  def delete
    @listing_template.destroy
    render json: { deleted: true }
  end

  private

  def set_listing_template
    @listing_template = ListingTemplate.find_or_create_by(account: current_account)
  end

  def listing_template_params
    params.permit(:category, :subcategory, :title, :grading_company, :condition, :description, :price,
                  :domestic_shipping, :international_shipping)
  end
end
