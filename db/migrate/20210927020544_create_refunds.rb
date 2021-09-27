class CreateRefunds < ActiveRecord::Migration[6.1]
  def change
    create_table :refunds do |t|
      t.bigint :order_id, null: false
      t.string :refund_id, null: false
      t.numeric :amount, precision: 12, scale: 4, null: false
      t.string :status, null: false
      t.string :reason, null: false
      t.string :notes, default: nil

      t.timestamps
    end

    add_foreign_key :refunds, :orders
    add_index :refunds, :order_id, unique: true
    add_column :orders, :cancelled_at, :datetime
  end
end
