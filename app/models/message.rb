class Message < ApplicationRecord
  belongs_to :sender, class_name: 'Account'
  belongs_to :recipient, class_name: 'Account'

  validates :sender_id, :recipient_id, :body, presence: true
  validates :body, length: { in: 1..10_000 }

  private

  def sender_cannot_be_recipient
    errors.add(:recipient_id, "You can't send yourself a message") if sender_id == recipient_id
  end
end
