class CreateOffers < ActiveRecord::Migration[6.1]
  def change
    create_table :offers do |t|
      t.bigint :listing_id, null: false
      t.bigint :buyer_id, null: false
      t.string :aasm_state, null: false, default: 'active'
      t.datetime :accepted_at
      t.datetime :rejected_at
      t.datetime :cancelled_at
      t.boolean :counter, null: false, default: false
      t.numeric :amount, precision: 12, scale: 4, default: 0
      t.string :currency, null: false, limit: 3
      t.string :destination_country, null: false, limit: 3
      t.numeric :shipping, precision: 12, scale: 4

      t.timestamps
    end

    add_foreign_key :offers, :listings
    add_foreign_key :offers, :accounts, column: :buyer_id
    add_index :offers, :listing_id
    add_index :offers, :buyer_id
    add_index :offers, :aasm_state

    create_table :counter_offers do |t|
      t.bigint :listing_id, null: false
      t.bigint :buyer_id, null: false
      t.string :aasm_state, null: false, default: 'active'
      t.datetime :accepted_at
      t.datetime :rejected_at
      t.datetime :cancelled_at
      t.numeric :amount, precision: 12, scale: 4, default: 0
      t.string :currency, null: false, limit: 3
      t.string :destination_country, null: false, limit: 3
      t.numeric :shipping, precision: 12, scale: 4

      t.timestamps
    end

    add_foreign_key :counter_offers, :listings
    add_foreign_key :counter_offers, :accounts, column: :buyer_id
    add_index :counter_offers, :listing_id
    add_index :counter_offers, :buyer_id
    add_index :counter_offers, :aasm_state

    add_column :listings, :accept_offers, :boolean, null: false, default: false
    add_column :listing_templates, :accept_offers, :boolean, null: false, default: false
  end
end
