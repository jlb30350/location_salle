class ChangeCapacityAndSurfaceToIntegerInRooms < ActiveRecord::Migration[6.1]
  def change
    change_column :rooms, :capacity, :integer
    change_column :rooms, :surface, :integer
  end
end
