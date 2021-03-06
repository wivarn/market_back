class CreateListings < ActiveRecord::Migration[6.1]
  def change
    create_table :listings do |t|
      t.references :account, null: false, foreign_key: true

      t.jsonb :photos

      t.string :category, null: false
      t.string :subcategory, null: false
      t.string :tags, array: true, default: []
      t.string :title, null: false
      t.string :grading_company
      t.numeric :condition, precision: 3, scale: 1, default: 0
      t.text :description

      t.string :currency, null: false, limit: 3
      t.numeric :price, precision: 12, scale: 4, default: 0
      t.numeric :domestic_shipping, precision: 12, scale: 4, default: 0
      t.numeric :international_shipping, precision: 12, scale: 4
      t.numeric :combined_shipping, precision: 12, scale: 4
      t.string :shipping_country, null: false, limit: 3

      t.string :aasm_state, null: false, default: 'draft'
      t.datetime :reserved_at

      t.index :category, using: 'btree'
      t.index :subcategory, using: 'btree'
      t.index :title, using: 'btree'
      t.index :grading_company, using: 'btree'
      t.index :condition, using: 'btree'
      t.index :currency, using: 'btree'
      t.index :price, using: 'btree'
      t.index :aasm_state, using: 'btree'

      t.timestamps
    end
  end
end
