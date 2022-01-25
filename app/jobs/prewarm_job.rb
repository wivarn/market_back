# frozen_string_literal: true

class PrewarmJob < ApplicationJob
  rate '5 minutes'
  def full_request_warm
    puts URI.parse("#{ENV['FRONT_END_BASE_URL']}/listings/#{Listing.publically_viewable.last.id}").read
  end
end
