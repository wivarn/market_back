# frozen_string_literal: true

Jets.application.routes.draw do
  prefix :v0 do
    resources :listings, param: :id do
      get :search, on: :collection
      post :bulk_create, on: :collection
      get :edit, on: :member
      post :presigned_put_urls, on: :member
      put :update_photo_identifiers, on: :member
      post :update_state, on: :member
      get :recent_by_category, on: :collection
    end

    resources :users, only: %i[show] do
      get :listings, on: :member
      get :list_roles, on: :collection
      put :update_role, on: :collection
    end

    resources :carts, only: %i[index delete], param: :seller_id do
      post :add_item, on: :member
      post :checkout, on: :member
      delete :remove_item, on: :member
    end

    resources :orders, only: %i[index show update], param: :id do
      post :update_state, on: :member
      post :refund, on: :member
      post :cancel, on: :member
    end

    resources :offers, only: %i[create], param: :id do
      get :purchase_offers, on: :collection
      get :sale_offers, on: :collection
      post :create_counter, on: :member
    end

    prefix :account do
      resource :profile, only: %i[show update] do
        get :presigned_put_url, to: 'profiles#presigned_put_url'
        put :update_picture_identifier, to: 'profiles#update_picture_identifier'
        get :settings, to: 'profiles#settings'
      end
      resource :email_settings, only: %i[show update]
      resource :address, only: %i[show update]
      resource :listing_template, only: %i[show update]
      resource :payments, only: %i[show] do
        post :link_account, on: :collection
        put :update_currency, on: :collection
      end
    end

    resources :messages, only: %i[index show create], param: :account_id

    prefix :webhooks do
      post :stripe, to: 'webhooks#stripe'
    end

    mount Auth, at: 'auth'
  end
end
