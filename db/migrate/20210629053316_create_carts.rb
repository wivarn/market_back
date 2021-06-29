class CreateCarts < ActiveRecord::Migration[6.1]
  def change
    create_table :carts do |t|
      t.bigint :account_id, null: false

      t.timestamps
    end

    add_foreign_key :carts, :accounts
    add_index :carts, :account_id, unique: true

    create_table :cart_items do |t|
      t.references :carts, null: false, foreign_key: true
      t.references :listings, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end
  end
end
