# frozen_string_literal: true

module Jets::Controller::Rack
  module EnvExtentions
    private

    def path_with_base_path
      @event['path']
    end

    def content_type
      headers['Content-Type'] || headers['content-type'] || Jets::Controller::DEFAULT_CONTENT_TYPE
    end
  end

  class Env
    prepend EnvExtentions
  end
end
