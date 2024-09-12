class PaymentsController < ApplicationController
  before_action :set_booking

  def new
    @stripe_publishable_key = Rails.application.credentials.stripe[:publishable_key]
    raise "La clé publique Stripe est manquante dans les variables d'environnement." if @stripe_publishable_key.nil?

    # Appel à la méthode `total_amount` de l'objet @booking
    @amount = @booking.total_amount  # Assure-toi que cette méthode est définie dans le modèle Booking
  end

  # Création de la transaction de paiement
  def create
    if params[:stripeToken].blank?
      flash[:error] = "Une erreur s'est produite avec votre carte, veuillez réessayer."
      return redirect_to new_room_booking_payment_path(@booking.room, @booking)
    end

    charge = Stripe::Charge.create(
      amount: (@booking.total_amount * 100).to_i,  # Montant en centimes
      currency: 'eur',
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
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id])
    @room = @booking.room
  end
end
