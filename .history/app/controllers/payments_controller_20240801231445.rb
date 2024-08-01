def confirmation
    @booking = Booking.find(params[:booking_id])
    @payment_success = params[:success] == 'true'
  
    respond_to do |format|
      format.json { render json: { success: @payment_success, booking: @booking } }
    end
  end