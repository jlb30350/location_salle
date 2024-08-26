class AddDurationCountsToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :day_count, :integer
    add_column :bookings, :week_count, :integer
    add_column :bookings, :month_count, :integer
    add_column :bookings, :semester_count, :integer
    add_column :bookings, :year_count, :integer
  end
end
