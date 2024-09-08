class AddDevisRequestedAtToBookings < ActiveRecord::Migration[7.1]
  def change
    add_column :bookings, :devis_requested_at, :datetime
  end
end
