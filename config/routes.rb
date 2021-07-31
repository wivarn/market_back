# frozen_string_literal: true

Jets.application.routes.draw do
  prefix :v0 do
    resources :listings, param: :id do
      get :search, on: :collection
      post :bulk_create, on: :collection
      get :edit, on: :member
      get :upload_photos_credentials, on: :member
      put :update_photo_keys, on: :member
      post :update_state, on: :member
      get :recent_by_category, on: :collection
    end

    resources :users, only: %i[show] do
      get :listings, on: :member
    end

    resources :carts, only: %i[index], param: :seller_id do
      post :add_item, on: :member
      post :checkout, on: :member
    end

    resources :orders, only: %i[index update], param: :id do
      post :update_state, on: :member
    end

    prefix :account do
      resource :profile, only: %i[show update] do
        get :upload_picture_credentials, to: 'profiles#upload_picture_credentials'
        put :update_picture_key, to: 'profiles#update_picture_key'
      end
      resource :address, only: %i[show update]
      resource :listing_template, only: %i[show update]
      resource :payments, only: %i[show] do
        post :link_account, on: :collection
      end
    end

    prefix :webhooks do
      post :stripe, to: 'webhooks#stripe'
    end

    mount Auth, at: 'auth'
  end
end
