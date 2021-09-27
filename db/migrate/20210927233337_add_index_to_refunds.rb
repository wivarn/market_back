class AddIndexToRefunds < ActiveRecord::Migration[6.1]
  def change
    add_index :refunds, :refund_id
  end
end
