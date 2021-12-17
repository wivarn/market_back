class AddFeedbackToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :recommend, :boolean
    add_column :orders, :feedback, :text
    add_column :orders, :feedback_at, :datetime
  end
end
