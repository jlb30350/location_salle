class CreateRooms < ActiveRecord::Migration[6.1]
  def change
    create_table :rooms do |t|
      t.string :name
      t.text :description
      t.integer :capacity
      t.decimal :price, precision: 8, scale: 2
      t.string :address
      t.string :city
      t.string :department
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
