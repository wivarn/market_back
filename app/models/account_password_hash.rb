class AccountPasswordHash < ApplicationRecord
  belongs_to :account, foreign_key: :id
end
