class AddIndexToUsers < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :id,                unique: true
  end
end
