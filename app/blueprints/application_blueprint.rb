# frozen_string_literal: true

class ApplicationBlueprint < Blueprinter::Base
  identifier :id
  fields :updated_at, :created_at
end
