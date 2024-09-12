class AddTotalAmountToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :total_amount, :decimal
  end
end
