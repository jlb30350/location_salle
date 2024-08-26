class PaymentsController < ApplicationController
  before_action :set_booking

  def new
    # Exemple : vous pouvez définir ici ce que vous devez passer à la vue
    @amount = @booking.total_amount
    @stripe_publishable_key = Rails.application.credentials.dig(:stripe, :publishable_key)
  end

  def create
    # Logique de création du paiement
    # Par exemple, vous pourriez traiter ici le paiement avec Stripe ou un autre service de paiement.
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id])
    @room = @booking.room
  end
end
