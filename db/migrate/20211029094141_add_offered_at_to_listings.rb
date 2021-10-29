class AddOfferedAtToListings < ActiveRecord::Migration[6.1]
  def change
    add_column :listings, :offered_at, :datetime
  end
end
