# frozen_string_literal: true

class RefundBlueprint < Blueprinter::Base
  fields :amount, :status, :reason, :notes, :updated_at
end
