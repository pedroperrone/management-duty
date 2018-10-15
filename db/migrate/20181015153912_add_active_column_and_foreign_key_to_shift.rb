class AddActiveColumnAndForeignKeyToShift < ActiveRecord::Migration[5.2]
  def change
    add_column :shifts, :active, :boolean, default: true
    add_reference :shifts, :origin_shift, index: true
    add_foreign_key :shifts, :shifts, column: :origin_shift_id
  end
end
