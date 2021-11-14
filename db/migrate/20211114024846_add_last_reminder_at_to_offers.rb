class AddLastReminderAtToOffers < ActiveRecord::Migration[6.1]
  def change
    add_column :offers, :last_reminder_at, :datetime, null: false, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
