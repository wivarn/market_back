class CreateEmailSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :email_settings do |t|
      t.bigint :account_id, null: false
      t.boolean :marketing, null: false, default: false

      t.timestamps
    end

    add_foreign_key :email_settings, :accounts
    add_index :email_settings, :account_id, unique: true
  end
end
