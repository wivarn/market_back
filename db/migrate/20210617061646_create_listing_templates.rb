class CreateListingTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :listing_templates do |t|
      t.bigint :account_id, null: false

      t.string :category
      t.string :subcategory
      t.string :tags, array: true, default: []
      t.string :title
      t.string :grading_company
      t.numeric :condition, precision: 3, scale: 1
      t.text :description

      t.numeric :price, precision: 12, scale: 4
      t.numeric :domestic_shipping, precision: 12, scale: 4
      t.numeric :international_shipping, precision: 12, scale: 4

      t.timestamps
    end

    add_foreign_key :listing_templates, :accounts
    add_index :listing_templates, :account_id, unique: true
  end
end
