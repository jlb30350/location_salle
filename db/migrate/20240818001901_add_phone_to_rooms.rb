class AddPhoneToRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :rooms, :phone, :string
  end
end
