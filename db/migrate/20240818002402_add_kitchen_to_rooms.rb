class AddKitchenToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :kitchen, :string
  end
end
