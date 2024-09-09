class AddAdditionalRentalOptionsToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :quarterly_rental, :boolean
    add_column :rooms, :semiannual_rental, :boolean
    add_column :rooms, :annual_rental, :boolean
  end
end
