class AddPaymentIntentToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :payment_intent_id, :string, default: nil
  end
end
