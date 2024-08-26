class BookingMailer < ApplicationMailer
    def confirmation_email(booking)
      @booking = booking
      mail(to: @booking.user.email, subject: 'Confirmation de votre réservation')
    end
  end
  