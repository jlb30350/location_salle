class AddPhoneToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :phone, :string
  end
end
