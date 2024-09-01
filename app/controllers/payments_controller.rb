class PaymentsController < ApplicationController
  before_action :set_booking

  def new
    @amount = @booking.total_amount
    @stripe_publishable_key = Rails.application.credentials.stripe[:publishable_key] # Utilisation de la clé Stripe publique
  end

  def create
    Stripe.api_key = Rails.application.credentials.stripe[:secret_key] # Utilisation de la clé Stripe secrète
    # Code de paiement Stripe ici
    # Assurez-vous que le stripeToken est présent dans les paramètres
    if params[:stripeToken].blank?
      flash[:error] = "Une erreur s'est produite avec votre carte, veuillez réessayer."
      return redirect_to new_room_booking_payment_path(@booking.room, @booking)
    end

    # Traitement du paiement via Stripe
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
    @room = @booking.room # Ajoutez cette ligne pour définir @room
  end
end
