class DevisPdfGenerator
    def initialize(booking)
      @booking = booking
    end
  
    def render
      Prawn::Document.new do |pdf|
        pdf.text "Devis pour la réservation #{@booking.id}", size: 30, style: :bold
        # Ajoutez plus de détails ici...
      end.render
    end
  end
  