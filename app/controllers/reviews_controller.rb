# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController
  before_action :set_booking
  before_action :ensure_booking_owner

  def new
    @review = @booking.build_review
  end

  def create
    @review = @booking.build_review(review_params)
    if @review.save
      redirect_to @booking.room, notice: 'Avis ajouté avec succès.'
    else
      render :new
    end
  end

  private

  def set_booking
    @booking = Booking.find(params[:booking_id])
  end

  def ensure_booking_owner
    unless @booking.user == current_user
      redirect_to root_path, alert: "Vous n'êtes pas autorisé à effectuer cette action."
    end
  end

  def review_params
    params.require(:review).permit(:rating, :content)
  end
end