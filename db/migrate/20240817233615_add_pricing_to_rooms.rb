class AddPricingToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :hourly_rate, :decimal, precision: 8, scale: 2, default: 0
    add_column :rooms, :daily_rate, :decimal, precision: 8, scale: 2, default: 0
    add_column :rooms, :weekly_rate, :decimal, precision: 8, scale: 2, default: 0
    add_column :rooms, :monthly_rate, :decimal, precision: 8, scale: 2, default: 0
    add_column :rooms, :weekend_rate, :decimal, precision: 8, scale: 2, default: 0
    add_column :rooms, :quarterly_rate, :decimal, precision: 8, scale: 2, default: 0
    add_column :rooms, :semiannual_rate, :decimal, precision: 8, scale: 2, default: 0
    add_column :rooms, :annual_rate, :decimal, precision: 8, scale: 2, default: 0
  end
end