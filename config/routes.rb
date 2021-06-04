# frozen_string_literal: true

Jets.application.routes.draw do
  prefix :v0 do
    resources :listings, param: :id do
      get :search, on: :collection
    end
    resource :profile, only: %i[show update]

    mount Auth, at: 'auth'
  end
end
