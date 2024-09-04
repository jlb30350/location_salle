class PaymentsController < ApplicationController
  before_action :set_booking

  def new
    if Rails.application.credentials.stripe.blank?
      raise "Stripe credentials not found. Please check your credentials file."
    end

    @amount = @booking.total_amount
    @stripe_publishable_key = Rails.application.credentials.stripe[:publishable_key]
  end

  def create
    if Rails.application.credentials.stripe[:secret_key].blank?
      raise "Stripe secret key not set. Please check your credentials file."
    end

    Stripe.api_key = Rails.application.credentials.stripe[:secret_key]

    if params[:stripeToken].blank?
      flash[:error] = "Une erreur s'est produite avec votre carte, veuillez réessayer."
      return redirect_to new_room_booking_payment_path(@booking.room, @booking)
    end

    begin
      charge = Stripe::Charge.create(
        amount: (@booking.total_amount * 100).to_i, # Montant en centimes
        currency: 'usd', # Utilisez la devise souhaitée
        source: params[:stripeToken],
        description: "Paiement pour la réservation #{@booking.id}"
      )

      if charge.paid
        flash[:notice] = "Paiement effectué avec succès!"
        redirect_to room_booking_path(@booking.room, @booking)
      else
        flash[:error] = "Le paiement a échoué. Veuillez essayer à nouveau."
        redirect_to new_room_booking_payment_path(@booking.room, @booking)
      end
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_room_booking_payment_path(@booking.room, @booking)
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id])
    @room = @booking.room
  end
end
