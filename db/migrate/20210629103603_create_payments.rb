class CreatePayments < ActiveRecord::Migration[6.1]
  def change
    create_table :payments do |t|
      t.bigint :account_id, null: false
      t.string :stripe_id, null: false
      t.string :currency, null: false, limit: 3, default: 'USD'

      t.timestamps
    end

    add_foreign_key :payments, :accounts
    add_index :payments, :account_id, unique: true
  end
end
