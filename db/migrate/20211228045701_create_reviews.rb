class CreateReviews < ActiveRecord::Migration[6.1]
  def change
    create_table :reviews do |t|
      t.bigint :order_id, null: false
      t.boolean :recommend, null: false
      t.text :feedback, default: nil
      t.string :reviewer, null: false

      t.timestamps
    end

    add_foreign_key :reviews, :orders
    add_index :reviews, :order_id
  end
end
