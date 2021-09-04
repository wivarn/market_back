class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.bigint :buyer_id, null: false
      t.bigint :seller_id, null: false
      t.string :aasm_state, null: false, default: 'reserved'
      t.datetime :reserved_at
      t.datetime :paid_at
      t.datetime :shipped_at
      t.datetime :refunded_at
      t.datetime :received_at
      t.string :tracking
      t.numeric :total, precision: 12, scale: 4, default: nil
      t.string :currency, limit: 3

      t.timestamps
    end

    add_foreign_key :orders, :accounts, column: :buyer_id
    add_foreign_key :orders, :accounts, column: :seller_id
    add_index :orders, :buyer_id
    add_index :orders, :seller_id

    create_table :order_items do |t|
      t.bigint :order_id, null: false
      t.bigint :listing_id, null: false
      t.numeric :shipping, precision: 12, scale: 4, default: 0, null: false

      t.timestamps
    end

    add_foreign_key :order_items, :orders
    add_foreign_key :order_items, :listings
    add_index :order_items, :listing_id, unique: true
  end
end
