class CreateListings < ActiveRecord::Migration[6.1]
  def change
    create_table :listings do |t|
      t.references :account, null: false

      t.string :photos, array: true, null: false

      t.string :category, null: false
      t.string :title, null: false
      t.string :grading_company
      t.string :condition, null: false
      t.text :description

      t.string :currency, null: false, limit: 3
      t.numeric :price, null: false, precision: 12, scale: 4
      t.numeric :domestic_shipping, null: false, precision: 12, scale: 4
      t.numeric :international_shipping, precision: 12, scale: 4

      t.string :status, null: false

      t.index :category, using: 'btree'
      t.index :title, using: 'btree'
      t.index :currency, using: 'btree'
      t.index :price, using: 'btree'
      t.index :status, using: 'btree'

      t.timestamps
    end
  end
end
