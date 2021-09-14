# frozen_string_literal: true

class MessageBlueprint < Blueprinter::Base
  fields :sender_id, :recipient_id, :body, :created_at

  view :with_correspondents do
    association :sender, blueprint: AccountBlueprint
    association :recipient, blueprint: AccountBlueprint
  end
end
