def confirmation
    @booking = Booking.find(params[:booking_id])
    @payment_success = params[:success] == 'true'
  end