class AddAddressToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :address, :string
  end
end
