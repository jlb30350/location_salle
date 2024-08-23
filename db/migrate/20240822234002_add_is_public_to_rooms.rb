class AddIsPublicToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :is_public, :boolean
  end
end
