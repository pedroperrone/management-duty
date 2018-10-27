class AddForeignKeysToShiftExchange < ActiveRecord::Migration[5.2]
  def change
      add_reference :shift_exchanges, :requested_shift, index: true
      add_foreign_key :shift_exchanges, :shifts, column: :requested_shift_id

      add_reference :shift_exchanges, :given_up_shift, index: true
      add_foreign_key :shift_exchanges, :shifts, column: :given_up_shift_id
  end
end
