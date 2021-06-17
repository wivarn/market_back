# frozen_string_literal: true

Jets.application.routes.draw do
  prefix :v0 do
    resources :listings, param: :id do
      get :search, on: :collection
    end

    prefix :account do
      resource :profile, only: %i[show update]
      resource :address, only: %i[show update]
      resource :listing_template, only: %i[show update]
    end

    mount Auth, at: 'auth'
  end
end
