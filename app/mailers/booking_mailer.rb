class BookingMailer < ApplicationMailer
  default from: 'noreply@jereserveunesalle.com'

  def booking_confirmation(booking)
    @booking = booking
    @user = @booking.user
    @room = @booking.room

    # Attachement du devis en PDF (si vous avez une méthode pour générer le devis en PDF)
    attachments['devis.pdf'] = generate_pdf(@booking)

    mail(to: @user.email, subject: 'Confirmation de réservation et devis')
  end

  def quote(booking)
    @booking = booking
    mail(to: @booking.user.email, subject: 'Votre devis pour la réservation')
  end
end

  private

  def generate_pdf(booking)
    # Remplacez par votre méthode pour générer le PDF du devis
    DevisPdfGenerator.new(booking).render
  end
end
