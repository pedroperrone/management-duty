class CreateShiftExchanges < ActiveRecord::Migration[5.2]
  def change
    create_table :shift_exchanges do |t|
      t.boolean :pending_admin_approval, default: true
      t.boolean :pending_user_approval, default: true
      t.boolean :approved_by_admin, default: false
      t.boolean :approved_by_user, default: false

      t.timestamps
    end
  end
end
