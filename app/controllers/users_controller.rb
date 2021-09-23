# frozen_string_literal: true

class UsersController < ApplicationController
  include ListingsHelper

  before_action :set_user, except: %i[update_role list_roles]
  before_action :enforce_admin!, only: %i[update_role list_roles]
  before_action :set_user_by_email, only: %i[update_role]

  def show
    render json: AccountBlueprint.render(@user, view: :with_recent_listings,
                                                destination_country: params[:destination_country])
  end

  def listings
    listings = @user.listings.active.order(updated_at: :desc, id: :asc)
    listings = filter_and_sort(listings, params)
    listings = listings.page(params[:page].to_i)

    render json: ListingBlueprint.render_as_json(listings, destination_country: params[:destination_country],
                                                           root: :listings,
                                                           meta: { total_pages: listings.total_pages })
  end

  def list_roles
    render json: AccountBlueprint.render(Account.all, view: :admin)
  end

  def update_role
    if params[:role] == 'admin'
      render json: {}, status: :forbidden
    elsif @user.update(role: params[:role])
      render json: AccountBlueprint.render(Account.all, view: :admin)
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

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
end
