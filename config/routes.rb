# frozen_string_literal: true

Jets.application.routes.draw do
  prefix :v0 do
    resources :listings, param: :id do
      get :search, on: :collection
      post :bulk_create, on: :collection
      get :edit, on: :member
      post :update_state, on: :member
    end

    resources :users, only: %i[show] do
      get :listings, on: :member
    end

    resources :carts, only: %i[show index], param: :seller_id do
      post :add_item, on: :member
      post :checkout, on: :member
    end

    prefix :account do
      resource :profile, only: %i[show update]
      resource :address, only: %i[show update]
      resource :listing_template, only: %i[show update]
      resource :payments, only: %i[show] do
        post :link_account, on: :collection
      end
    end

    mount Auth, at: 'auth'
  end
end
