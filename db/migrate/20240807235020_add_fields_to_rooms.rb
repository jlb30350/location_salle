class AddFieldsToRooms < ActiveRecord::Migration[6.1]
  def change
    add_column :rooms, :name, :string
    add_column :rooms, :description, :text
    add_column :rooms, :capacity, :integer
    add_column :rooms, :price, :decimal, precision: 10, scale: 2
    add_column :rooms, :address, :string
    add_column :rooms, :city, :string
    add_column :rooms, :department, :string
  end
end
