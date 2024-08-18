class AddMailToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :mail, :string
  end
end
