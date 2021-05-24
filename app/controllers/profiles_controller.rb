# frozen_string_literal: true

class ProfilesController < ApplicationController
  before_action :authenticate!
  def show
    render json: current_account
  end

  def update; end
end
