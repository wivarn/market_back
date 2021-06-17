class CreateListingTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :listing_templates do |t|
      t.bigint :account_id, null: false

      t.string :category, default: ''
      t.string :subcategory, default: ''
      t.string :tags, array: true, default: []
      t.string :title, default: ''
      t.string :grading_company, default: ''
      t.numeric :condition, precision: 3, scale: 1, default: 2
      t.text :description, default: ''

      t.numeric :price, precision: 12, scale: 4, default: 0.25
      t.numeric :domestic_shipping, precision: 12, scale: 4, default: 0
      t.numeric :international_shipping, precision: 12, scale: 4, default: 0

      t.timestamps
    end

    add_foreign_key :listing_templates, :accounts
    add_index :listing_templates, :account_id, unique: true
  end
end
