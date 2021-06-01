class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.string :street1, null: false
      t.string :street2
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip, null: false
      t.string :country, null: false
      t.references :account, null: false, foreign_key: true, column: :id

      t.timestamps
    end
  end
end
