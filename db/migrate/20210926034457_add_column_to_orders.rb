class AddColumnToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :pending_shipment_at, :datetime
    remove_column :orders, :paid_at
  end
end
