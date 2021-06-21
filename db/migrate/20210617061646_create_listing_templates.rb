class CreateListingTemplates < ActiveRecord::Migration[6.1]
  def change
    create_table :listing_templates do |t|
      t.bigint :account_id, null: false

      t.string :category, default: nil
      t.string :subcategory, default: nil
      t.string :tags, array: true, default: nil
      t.string :title, default: nil
      t.string :grading_company, default: nil
      t.numeric :condition, precision: 3, scale: 1, default: nil
      t.text :description, default: nil

      t.numeric :price, precision: 12, scale: 4, default: nil
      t.numeric :domestic_shipping, precision: 12, scale: 4, default: nil
      t.numeric :international_shipping, precision: 12, scale: 4, default: nil

      t.timestamps
    end

    add_foreign_key :listing_templates, :accounts
    add_index :listing_templates, :account_id, unique: true
  end
end
