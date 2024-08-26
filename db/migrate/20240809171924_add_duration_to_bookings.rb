class AddDurationCountsToBookings < ActiveRecord::Migration[6.0]
  def change
    add_column :bookings, :hour_count, :integer
    add_column :bookings, :day_count, :integer
    add_column :bookings, :week_count, :integer
    add_column :bookings, :month_count, :integer
    add_column :bookings, :year_count, :integer
  end
end
