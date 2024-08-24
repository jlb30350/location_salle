class ChangeColumnsInRooms < ActiveRecord::Migration[6.1]
  def change
    change_column :rooms, :capacity, :integer
    change_column :rooms, :surface, :integer
    change_column :rooms, :address, :string
    change_column :rooms, :city, :string
    change_column :rooms, :department, :string
  end
end
