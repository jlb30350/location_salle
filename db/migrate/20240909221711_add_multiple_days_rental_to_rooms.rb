class AddMultipleDaysRentalToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :multiple_days_rental, :boolean
    add_column :rooms, :multiple_days_rate, :decimal
  end
end
