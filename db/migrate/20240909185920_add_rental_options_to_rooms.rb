class AddRentalOptionsToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :hourly_rental, :boolean
    add_column :rooms, :daily_rental, :boolean
    add_column :rooms, :weekly_rental, :boolean
    add_column :rooms, :monthly_rental, :boolean
    add_column :rooms, :weekend_rental, :boolean
  end
end
