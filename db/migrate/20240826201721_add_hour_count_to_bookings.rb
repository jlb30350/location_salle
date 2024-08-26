class AddHourCountToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :hour_count, :integer
  end
end
