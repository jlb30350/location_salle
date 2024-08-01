# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
    before_action :set_booking
  
    def new
      @amount = @booking.total_amount
      @stripe_publishable_key = Rails.application.credentials.dig(:stripe, :publishable_key)
    end
  
    def create
        Rails.logger.debug "Starting payment process for booking #{@booking.id}"
        @amount = (@booking.total_amount * 100).to_i # montant en centimes
        Rails.logger.debug "Amount to charge: #{@amount}"
      
        begin
          customer = Stripe::Customer.create({
            email: params[:stripeEmail],
            source: params[:stripeToken],
          })
          Rails.logger.debug "Stripe customer created: #{customer.id}"
      
          charge = Stripe::Charge.create({
            customer: customer.id,
            amount: @amount,
            description: 'Réservation de salle',
            currency: 'eur',
          })
          Rails.logger.debug "Stripe charge created: #{charge.id}"
      
          @booking.update(status: 'confirmed')
          flash[:notice] = "Paiement effectué avec succès. Votre réservation est confirmée."
          Rails.logger.info "Payment successful for booking #{@booking.id}"
          redirect_to confirmation_payments_path(booking_id: @booking.id, success: true)
        rescue Stripe::CardError => e
          Rails.logger.error "Stripe error: #{e.message}"
          flash[:alert] = "Erreur lors du paiement : #{e.message}"
          redirect_to confirmation_payments_path(booking_id: @booking.id, success: false)
        rescue => e
          Rails.logger.error "Unexpected error during payment: #{e.message}"
          flash[:alert] = "Une erreur inattendue s'est produite"
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