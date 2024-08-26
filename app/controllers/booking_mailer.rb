class BookingMailer < ApplicationMailer
    def invoice_email(booking)
      @booking = booking
      @payment_url = new_room_booking_payment_url(room_id: @booking.room.id, booking_id: @booking.id)  # Utiliser _url pour une URL complète
      mail(to: @booking.user.email, subject: 'Votre devis')
    end
  end
  