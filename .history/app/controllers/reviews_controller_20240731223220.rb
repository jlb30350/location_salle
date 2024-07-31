# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController
  def create
    @room = Room.find(params[:room_id])
    @review = @room.reviews.build(review_params)
    @review.user = current_user
    if @review.save
      redirect_to @room, notice: 'Avis ajouté avec succès.'
    else
      redirect_to @room, alert: 'Erreur lors de l'ajout de l'avis.'
    end
  end

  private

  def review_params
    params.require(:review).permit(:rating, :content)
  end
end