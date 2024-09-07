class PaymentsController < ApplicationController
  before_action :set_booking
  def new
    @stripe_publishable_key = ENV['STRIPE_PUBLISHABLE_KEY']

    if @stripe_publishable_key.nil?
      raise "La clé publique Stripe est manquante dans les variables d'environnement."
    end
  
    @stripe_publishable_key = stripe_credentials[:publishable_key]
    @amount = @booking.total_amount
  end

  def create
    stripe_credentials = Rails.application.credentials.stripe
    if stripe_credentials[:secret_key].blank?
      raise "Stripe secret key not set. Please check your credentials file."
    end

    Stripe.api_key = stripe_credentials[:secret_key]

    if params[:stripeToken].blank?
      flash[:error] = "Une erreur s'est produite avec votre carte, veuillez réessayer."
      return redirect_to new_room_booking_payment_path(@booking.room, @booking)
    end

    begin
      charge = Stripe::Charge.create(
        amount: (@booking.total_amount * 100).to_i, # Montant en centimes
        currency: 'usd',
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
