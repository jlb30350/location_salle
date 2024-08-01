# app/controllers/promotions_controller.rb
class PromotionsController < ApplicationController
    before_action :set_room
    before_action :set_promotion, only: [:edit, :update, :destroy]
  
    def index
      @promotions = @room.promotions
    end
  
    def new
      @promotion = @room.promotions.build
    end
  
    def create
      @promotion = @room.promotions.build(promotion_params)
      if @promotion.save
        redirect_to room_promotions_path(@room), notice: 'Promotion créée avec succès.'
      else
        render :new
      end
    end
  
    def edit
    end
  
    def update
      if @promotion.update(promotion_params)
        redirect_to room_promotions_path(@room), notice: 'Promotion mise à jour avec succès.'
      else
        render :edit
      end
    end
  
    def destroy
      @promotion.destroy
      redirect_to room_promotions_path(@room), notice: 'Promotion supprimée avec succès.'
    end
  
    private
  
    def set_room
      @room = Room.find(params[:room_id])
    end
  
    def set_promotion
      @promotion = @room.promotions.find(params[:id])
    end
  
    def promotion_params
      params.require(:promotion).permit(:discount_percentage, :start_date, :end_date)
    end
  end