# app/models/promotion.rb
class Promotion < ApplicationRecord
    belongs_to :room
    validates :discount_percentage, presence: true, inclusion: { in: 1..100 }
    validates :start_date, :end_date, presence: true
    validate :end_date_after_start_date
    validate :no_overlapping_promotions
  
    scope :active, -> { where('start_date <= ? AND end_date >= ?', Date.today, Date.today) }
  
    def active?
      start_date <= Date.today && end_date >= Date.today
    end
  
    private
  
    def end_date_after_start_date
      return if end_date.blank? || start_date.blank?
  
      if end_date < start_date
        errors.add(:end_date, "doit être après la date de début")
      end
    end
  
    def no_overlapping_promotions
      overlapping_promotions = room.promotions.where('(start_date <= ? AND end_date >= ?) OR (start_date <= ? AND end_date >= ?)', start_date, start_date, end_date, end_date)
      if overlapping_promotions.exists?
        errors.add(:base, "Il existe déjà une promotion pour cette période")
      end
    end
  end
  
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