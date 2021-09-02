# frozen_string_literal: true

class ListingsController < ApplicationController
  before_action :authenticate_and_enforce_seller!,
                only: %i[index create bulk_create edit update update_state presigned_put_urls update_photo_identifiers
                         delete]
  before_action :set_listing, only: %i[show]
  before_action :set_listing_through_account,
                only: %i[edit update update_state presigned_put_urls update_photo_identifiers delete]
  before_action :enforce_listing_prerequisites!, only: %i[create bulk_create update]
  before_action :enforce_editable!, only: %i[update]
  before_action :enforce_destroyable!, only: %i[destroy]
  before_action :enforce_number_of_photos!, only: %i[presigned_put_urls]
  before_action :ensure_identifiers_present!, only: %i[update_photo_identifiers]

  def index
    scope = params[:state] || :active
    listings = current_account.listings.send(scope).order(updated_at: :desc, id: :asc)
    listings = filter_and_sort(listings, params)

    render json:
      { listings: ListingBlueprint.render_as_json(listings, destination_country: current_account.address.country),
        total_pages: listings.total_pages }
  end

  def search
    listings = filter_and_sort(Listing.active, params)
    render json:
      { listings: ListingBlueprint.render_as_json(listings, destination_country: params[:destination_country]),
        total_pages: listings.total_pages }
  end

  # used in the home page
  def recent_by_category
    sports_cards = Listing.active.ships_to(params[:destination_country]).sports_cards.order(created_at: :desc).limit(4)
    trading_cards = Listing.active.ships_to(params[:destination_country]).trading_cards.order(created_at: :desc).limit(4)
    collectibles = Listing.active.ships_to(params[:destination_country]).collectibles.order(created_at: :desc).limit(4)

    render json: {
      sports_cards: ListingBlueprint.render_as_json(sports_cards, destination_country: params[:destination_country]),
      trading_cards: ListingBlueprint.render_as_json(trading_cards, destination_country: params[:destination_country]),
      collectibles: ListingBlueprint.render_as_json(collectibles, destination_country: params[:destination_country])
    }
  end

  def show
    render json: ListingBlueprint.render(@listing, view: :buyer, destination_country: params[:destination_country])
  end

  def create
    listing = current_account.listings.new(listing_params.merge(currency: current_account.payment.currency,
                                                                shipping_country: current_account.address.country))
    listing.aasm.fire(state_transition) if state_transition

    if listing.save
      render json: ListingBlueprint.render(listing, view: :seller), status: :created
    else
      render json: listing.errors, status: :unprocessable_entity
    end
  end

  def bulk_create
    currency = current_account.payment.currency
    country = current_account.address.country
    listings =
      current_account
      .listings
      .create_with(created_at: Time.now, updated_at: Time.now,
                   currency: currency, shipping_country: country)
      .insert_all(bulk_create_params[:listings])

    render json: listings, status: :created
  end

  def edit
    render json: ListingBlueprint.render(@listing, view: :seller)
  end

  def update
    @listing.aasm.fire(state_transition) if state_transition
    if @listing.update(listing_params)
      render json: ListingBlueprint.render(@listing, view: :seller)
    else
      render json: @listing.errors, status: :unprocessable_entity
    end
  end

  def update_state
    @listing.aasm.fire(state_transition)
    if @listing.save
      render json: ListingBlueprint.render(@listing, view: :seller)
    else
      render json: @listing.errors, status: :unprocessable_entity
    end
  end

  iam_policy({
               action: ['s3:PutObject', 's3:PutObjectAcl'],
               effect: 'Allow',
               resource: "#{ENV['PUBLIC_ASSETS_BUCKET_ARN']}/uploads/listing/photos/*"
             })
  def presigned_put_urls
    render json: ImageUploader.new(@listing, 'photos').presigned_put_urls(params[:filenames])
  end

  iam_policy({
               action: ['s3:DeleteObject'],
               effect: 'Allow',
               resource: "#{ENV['PUBLIC_ASSETS_BUCKET_ARN']}/uploads/listing/photos/*"
             })
  def update_photo_identifiers
    @listing.write_attribute(:photos, params[:identifiers])
    if @listing.save
      render json: ListingBlueprint.render(@listing, view: :seller)
    else
      render json: @listing.errors, status: :unprocessable_entity
    end
  end

  iam_policy({
               action: ['s3:DeleteObject'],
               effect: 'Allow',
               resource: "#{ENV['PUBLIC_ASSETS_BUCKET_ARN']}/uploads/listing/photos/*"
             })
  def delete
    @listing.destroy
    render json: { deleted: true }
  end

  private

  def set_listing
    @listing = Listing.active.find(params[:id])
  end

  def set_listing_through_account
    @listing = current_account.listings.find(params[:id])
  end

  def authenticate_and_enforce_seller!
    authenticate!
    return if current_account.seller?

    render json: { error: 'Selling has not been enabled for you' }, status: :forbidden
  end

  def enforce_listing_prerequisites!
    return if current_account.address && current_account.payment

    render json: { error: 'Address and Stripe connection must be set before creating listings' }, status: :forbidden
  end

  def enforce_editable!
    return if @listing.editable?

    render json: { error: 'Only draft, active and removed listings can be updated' }, status: :unprocessable_entity
  end

  def enforce_destroyable!
    return unless @listing.draft?

    render json: { error: 'Only drafts can be deleted' }, status: :unprocessable_entity
  end

  def enforce_number_of_photos!
    count = params[:filenames].count
    return if count >= 1 || count <= 10

    render json: { error: 'Can only have between 1 and 10 photos' }, status: :bad_request
  end

  def ensure_identifiers_present!
    unless params[:identifiers]
      render json: { error: '"identifiers" is a required param' },
             status: :unprocessable_entity
    end
  end

  def listing_params
    params.permit({ photos: [] }, :category, :subcategory, :title, :grading_company, :condition, :description, :price,
                  :domestic_shipping, :international_shipping, :combined_shipping)
  end

  def state_transition
    params[:state_transition]
  end

  def bulk_create_params
    params.permit(listings: %i[category subcategory title grading_company condition description price
                               domestic_shipping international_shipping combined_shipping])
  end

  def filter_and_sort(listings, params)
    listings = filter(listings, params)
    listings = sort(listings, params[:sort])

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
    if filters[:destination_country].present?
      listings = listings.where('shipping_country = :country OR international_shipping IS NOT NULL',
                                country: filters[:destination_country])
    end
    listings = listings.where(shipping_country: params[:shipping_country]) if params[:shipping_country]
    listings
  end

  def sort(listings, order)
    case order
    when 'priceLow'
      listings.reorder(price: :asc, id: :asc)
    when 'priceHigh'
      listings.reorder(price: :desc, id: :asc)
    when 'priceShipLow'
      listings.select('*, (price + domestic_shipping) AS total_price').reorder(total_price: :asc, id: :asc)
    when 'priceShipHigh'
      listings.select('*, (price + domestic_shipping) AS total_price').reorder(total_price: :desc, id: :asc)
    when 'newest'
      listings.reorder(updated_at: :desc, id: :asc)
    when 'oldest'
      listings.reorder(updated_at: :asc, id: :asc)
    else
      listings
    end
  end
end
