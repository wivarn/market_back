# frozen_string_literal: true

class PrewarmJob < ApplicationJob
  rate '5 minutes'
  def full_request_warm
    puts URI.parse("https://api.#{ENV['DOMAIN']}/v0/listings/#{Listing.publically_viewable.first.id}").read
  end
end
