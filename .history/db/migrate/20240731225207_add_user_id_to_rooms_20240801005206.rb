class AddUserIdToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :user_id, :integer
  end
end
