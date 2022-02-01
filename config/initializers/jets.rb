# frozen_string_literal: true

module Jets
  module BareControllerExtentions
    private

    def process!
      status, headers, body = dispatch!
      adapter = Jets::Controller::Rack::Adapter.new(event, context)
      adapter.convert_to_api_gateway(status, headers, body)
    end
  end

  class BareController
    prepend BareControllerExtentions
  end
end
