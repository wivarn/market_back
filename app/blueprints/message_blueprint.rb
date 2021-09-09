# frozen_string_literal: true

class MessageBlueprint < Blueprinter::Base
  fields :sender_id, :recipient_id, :body, :created_at
end
