# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, except: %i[update_role list_roles]
  before_action :enforce_admin!, only: %i[update_role list_roles]
  before_action :set_user_by_email, only: %i[update_role]

  def show
    render json: AccountBlueprint.render(@user, view: :with_recent_listings,
                                                destination_country: params[:destination_country])
  end

  def listings
    listings = @user.listings.active.ships_to(params[:destination_country] || 'USA').order(updated_at: :desc, id: :asc)
    listings = sort(listings, params[:sort])
    listings = listings.page(params[:page].to_i + 1)

    render json:
      { listings: ListingBlueprint.render_as_json(listings, destination_country: params[:destination_country]),
        total_pages: listings.total_pages }
  end

  def list_roles
    render json: AccountBlueprint.render(seller_list, view: :name_email_role)
  end

  def update_role
    if params[:role] == 'admin'
      render json: {}, status: :forbidden
    elsif @user.update(role: params[:role])
      render json: AccountBlueprint.render(seller_list, view: :name_email_role)
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def seller_list
    Account.where(role: Account::SELLERS)
  end

  def set_user
    @user = Account.find(params[:user_id])
  end

  def enforce_admin!
    authenticate!
    return if current_account.admin?

    render json: {}, status: :forbidden
  end

  def set_user_by_email
    @user = Account.find_by_email(params[:email])

    return if @user

    render json: {}, status: :not_found
  end

  def sort(listings, order)
    case order
    when 'priceLow'
      listings.order(price: :asc, id: :asc)
    when 'priceHigh'
      listings.order(price: :desc, id: :asc)
    when 'priceShipLow'
      listings.select('*, (price + domestic_shipping) AS total_price').order(total_price: :asc, id: :asc)
    when 'priceShipHigh'
      listings.select('*, (price + domestic_shipping) AS total_price').order(total_price: :desc, id: :asc)
    when 'newest'
      listings.order(updated_at: :desc, id: :asc)
    when 'oldest'
      listings.order(updated_at: :asc, id: :asc)
    else
      listings
    end
  end
end
