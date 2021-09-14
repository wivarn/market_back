class Message < ApplicationRecord
  belongs_to :sender, class_name: 'Account'
  belongs_to :recipient, class_name: 'Account'

  validates :sender_id, :recipient_id, :body, presence: true
  validates :body, length: { in: 1..10_000 }

  SELECT_LATEST = <<~QUERY.freeze
    DISTINCT ON (correspondent_id) *,
    (CASE WHEN sender_id = :current_id
      THEN recipient_id
      ELSE sender_id
    END) AS correspondent_id
  QUERY

  scope :latest_for, lambda { |account_id|
    select('*').from(
      select(sanitize_sql_array([SELECT_LATEST, { current_id: account_id }]))
      .where('sender_id = :current_id OR recipient_id = :current_id', current_id: account_id)
      .order(:correspondent_id, created_at: :desc)
    ).order(created_at: :desc)
  }

  private

  def sender_cannot_be_recipient
    errors.add(:recipient_id, "You can't send yourself a message") if sender_id == recipient_id
  end
end
