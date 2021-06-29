class CreateStripeConnection < ActiveRecord::Migration[6.1]
  def change
    create_table :stripe_connections do |t|
      t.bigint :account_id, null: false
      t.string :stripe_account, null: false

      t.timestamps
    end

    add_foreign_key :stripe_connections, :accounts
    add_index :stripe_connections, :account_id, unique: true
  end
end
