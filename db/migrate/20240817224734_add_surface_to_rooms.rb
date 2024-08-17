class AddSurfaceToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :surface, :integer
  end
end
