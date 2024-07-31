# app/models/promotion.rb
class Promotion < ApplicationRecord
    belongs_to :room
    validates :discount_percentage, presence: true, inclusion: { in: 1..100 }
    validates :start_date, :end_date, presence: true
    validate :end_date_after_start_date
  end
  
  # app/controllers/promotions_controller.rb
  class PromotionsController < ApplicationController
    def new
      @room = Room.find(params[:room_id])
      @promotion = @room.promotions.build
    end
  
    def create
      @room = Room.find(params[:room_id])
      @promotion = @room.promotions.build(promotion_params)
      if @promotion.save
        redirect_to @room, notice: 'Promotion créée avec succès.'
      else
        render :new
      end
    end
  
    private
  
    def promotion_params
      params.require(:promotion).permit(:discount_percentage, :start_date, :end_date)
    end
  end