class AddExpiredAtToOffers < ActiveRecord::Migration[6.1]
  def change
    add_column :offers, :expired_at, :datetime
    add_column :offers, :paid_at, :datetime
  end
end
