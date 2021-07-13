class CreateCarts < ActiveRecord::Migration[6.1]
  def change
    create_table :carts do |t|
      t.bigint :account_id, null: false
      t.bigint :seller_id, null: false

      t.timestamps
    end

    add_foreign_key :carts, :accounts
    add_foreign_key :carts, :accounts, column: :seller_id
    add_index :carts, :account_id

    create_table :cart_items do |t|
      t.bigint :cart_id, null: false
      t.bigint :listing_id, null: false
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_foreign_key :cart_items, :carts
    add_foreign_key :cart_items, :listings
    add_index :cart_items, %i[cart_id listing_id], unique: true
  end
end
