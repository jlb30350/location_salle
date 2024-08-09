class AddDurationToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :duration, :string
  end
end
