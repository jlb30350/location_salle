# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
    before_action :set_booking
  
    def new
      @amount = @booking.total_amount
      @stripe_publishable_key = Rails.application.credentials.dig(:stripe, :publishable_key)
    end
  
    def create
      @amount = (@booking.total_amount * 100).to_i # montant en centimes
  
      begin
        customer = Stripe::Customer.create({
          email: params[:stripeEmail],
          source: params[:stripeToken],
        })
  
        charge = Stripe::Charge.create({
          customer: customer.id,
          amount: @amount,
          description: 'Réservation de salle',
          currency: 'eur',
        })
  
        @booking.update(status: 'confirmed')
        flash[:notice] = "Paiement effectué avec succès. Votre réservation est confirmée."
        redirect_to confirmation_payments_path(booking_id: @booking.id, success: true)
      rescue Stripe::CardError => e
        flash[:alert] = "Erreur lors du paiement : #{e.message}"
        redirect_to confirmation_payments_path(booking_id: @booking.id, success: false)
      end
    end
  
    def confirmation
      Rails.logger.info "Confirmation action called with params: #{params.inspect}"
      @booking = Booking.find(params[:booking_id])
      @payment_success = params[:success] == 'true'
  
      respond_to do |format|
        format.html
        format.json { render json: { success: @payment_success, booking: @booking } }
      end
    end
  
    private
  
    def set_booking
      @booking = Booking.find(params[:booking_id])
    end
  end