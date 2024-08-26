class AddEmailToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :email, :string
  end
end
