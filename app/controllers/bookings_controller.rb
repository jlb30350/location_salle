class RoomsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search, :bookings]
  before_action :set_room, only: [:show, :edit, :update, :destroy, :delete_main_photo, :delete_additional_photo, :availability, :bookings, :get_form]
  before_action :ensure_bailleur, only: [:new, :create, :edit, :update, :destroy, :delete_main_photo, :delete_additional_photo]
  before_action :ensure_owner, only: [:edit, :update, :destroy, :delete_main_photo, :delete_additional_photo]
  before_action :ensure_bailleur_or_correct_visibility, only: [:show]

  # Liste des salles
  def index
    @rooms = if user_signed_in? && current_user.bailleur?
               current_user.rooms
             else
               Room.where(is_public: true)
             end
  end

  # Rechercher des salles
  def search
    if params[:query].present?
      query = params[:query]
      @rooms = Room.where("name LIKE ? OR department LIKE ?", "%#{query}%", "%#{query}%")
    else
      @rooms = []
    end
    render :search
  end

  # Créer une nouvelle salle
  def new
    @room = Room.new(
      hourly_rate: 1,
      daily_rate: 1,
      multiple_days_rate: 1,
      weekly_rate: 1,
      weekend_rate: 1,
      monthly_rate: 1,
      quarterly_rate: 1,
      semiannual_rate: 1,
      annual_rate: 1,
      hourly_rental: true,
      daily_rental: true,
      multiple_days_rental: true,
      weekly_rental: true,
      weekend_rental: true,
      monthly_rental: true,
      quarterly_rental: true,
      semiannual_rental: true,
      annual_rental: true
    )
  end

  # Afficher une salle spécifique
  def show
    Rails.logger.debug "Room found: #{@room.inspect}"
    if @room
      @booking = @room.bookings.new
      if user_signed_in?
        @detailed_info = {
          address: @room.address,
          surface: @room.surface,
          hourly_rate: @room.hourly_rate,
          daily_rate: @room.daily_rate,
          weekly_rate: @room.weekly_rate,
          monthly_rate: @room.monthly_rate,
          weekend_rate: @room.weekend_rate,
          quarterly_rate: @room.quarterly_rate,
          semiannual_rate: @room.semiannual_rate,
          annual_rate: @room.annual_rate
        }
      end

      begin
        @year = params[:year] ? params[:year].to_i : Date.today.year
        @month = params[:month] ? params[:month].to_i : Date.today.month

        first_day_of_month = Date.new(@year, @month, 1)
        last_day_of_month = first_day_of_month.end_of_month

        @bookings = @room.bookings.where('start_date <= ? AND end_date >= ?', last_day_of_month, first_day_of_month)
      rescue ArgumentError
        flash[:alert] = "Date invalide"
        redirect_to rooms_path and return
      end
    else
      redirect_to rooms_path, alert: 'Salle non trouvée.' and return
    end
  end

  # Créer une nouvelle salle
  def create
    Rails.logger.debug "Paramètres reçus pour la création de la salle: #{params[:room].inspect}"
    @room = current_user.rooms.new(room_params)

    if @room.save
      # Gestion des photos après la sauvegarde
      @room.main_photo.attach(params[:room][:main_photo]) if params[:room][:main_photo].present?
      @room.additional_photos.attach(params[:room][:additional_photos]) if params[:room][:additional_photos].present?

      redirect_to @room, notice: 'Salle ajoutée avec succès.'
    else
      render :new
    end
  end

  # Mettre à jour une salle
  def update
    if @room.update(room_params)
      @room.main_photo.attach(params[:room][:main_photo]) if params[:room][:main_photo].present?
      @room.additional_photos.attach(params[:room][:additional_photos]) if params[:room][:additional_photos].present?

      redirect_to @room, notice: 'Salle mise à jour avec succès.'
    else
      render :edit
    end
  end

  # Supprimer une salle
  def destroy
    if @room.destroy
      flash[:notice] = 'Salle supprimée avec succès.'
      redirect_to rooms_path
    else
      flash[:alert] = "Impossible de supprimer la salle."
      redirect_to rooms_path
    end
  end

  # Action pour obtenir le formulaire en fonction de la durée
  def get_form
    duration = params[:duration]
    start_date = params[:start_date]
    end_date = params[:end_date]

    case duration
    when 'hour'
      @message = "Formulaire pour une réservation d'une heure à partir du #{start_date}"
    when 'day'
      @message = "Formulaire pour une réservation d'un jour à partir du #{start_date}"
    when 'multiple_days'
      @message = "Formulaire pour une réservation de plusieurs jours, du #{start_date} au #{end_date}"
    when 'weekend'
      @message = "Formulaire pour un week-end à partir du #{start_date}"
    when 'week'
      @message = "Formulaire pour une semaine à partir du #{start_date}"
    when 'month'
      @message = "Formulaire pour un mois à partir du #{start_date}"
    when 'quarter'
      @message = "Formulaire pour un trimestre à partir du #{start_date}"
    when 'semiannual'
      @message = "Formulaire pour un semestre à partir du #{start_date}"
    when 'year'
      @message = "Formulaire pour une année à partir du #{start_date}"
    else
      @message = "Durée non reconnue"
    end

    respond_to do |format|
      format.html { render partial: 'form_partial', locals: { message: @message } }
      format.json { render json: { message: @message } }
    end
  end

  private

  def room_params
    params.require(:room).permit(:name, :description, :address, :city, :department, :surface, :capacity, :mail, :phone, :kitchen,
                                 :hourly_rental, :hourly_rate, :daily_rental, :daily_rate, :multiple_days_rental, :multiple_days_rate,
                                 :weekly_rental, :weekly_rate, :weekend_rental, :weekend_rate, :monthly_rental, :monthly_rate,
                                 :quarterly_rental, :quarterly_rate, :semiannual_rental, :semiannual_rate, :annual_rental, :annual_rate,
                                 :main_photo, additional_photos: [])
  end

  def ensure_bailleur
    redirect_to root_path, alert: "Vous devez être un bailleur pour effectuer cette action." unless current_user&.bailleur?
  end

  def set_room
    @room = Room.find(params[:room_id] || params[:id])
    redirect_to rooms_path, alert: "Salle non trouvée." unless @room
  end

  def ensure_owner
    redirect_to rooms_path, alert: "Vous n'avez pas les droits pour gérer cette salle." unless current_user.id == @room.user_id
  end

  def ensure_bailleur_or_correct_visibility
    redirect_to root_path, alert: "Accès non autorisé" unless room_visible_to_current_user?(@room)
  end

  def room_visible_to_current_user?(room)
    room.is_public || (user_signed_in? && (current_user.bailleur? || current_user.loueur?))
  end
end
