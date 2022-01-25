# frozen_string_literal: true

class PrewarmJob < ApplicationJob
  rate '5 minutes'
  def full_request_warm
    uri = URI("#{ENV['FRONT_END_BASE_URL']}/listings/#{Listing.publically_viewable.last.id}")
    res = Net::HTTP.get_response(uri)
    puts res.code
  end
end
