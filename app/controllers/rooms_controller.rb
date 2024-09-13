class RoomsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :search, :bookings, :availability]
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

  def get_form
    # Récupérer les paramètres envoyés par la requête
    duration = params[:duration]
    start_date = params[:start_date]
    end_date = params[:end_date]
    room_id = params[:room_id]

    # Assurez-vous que ces variables existent
    if duration.present? && start_date.present? && room_id.present?
      @room = Room.find(room_id)

      # Vous pouvez définir un formulaire différent ou des informations en fonction de la durée et des dates
      render partial: 'bookings/form', locals: { duration: duration, start_date: start_date, end_date: end_date }
    else
      render plain: "Paramètres manquants", status: :bad_request
    end
  end
end

  # Rechercher des salles
  def search
    if params[:query].present?
      query = params[:query]
      # Recherche par nom ou département
      @rooms = Room.where("name LIKE ? OR department LIKE ?", "%#{query}%", "%#{query}%")
    else
      @rooms = []
    end
    render :search
  end

  # Afficher la disponibilité d'une salle
  def availability
    @room = Room.find(params[:id])
    
    # Définit l'année et le mois à partir des paramètres ou utilise les valeurs actuelles
    @year = params[:year] ? params[:year].to_i : Date.today.year
    @month = params[:month] ? params[:month].to_i : Date.today.month
  
    # Validation pour s'assurer que le mois est valide (entre 1 et 12)
    if @month < 1 || @month > 12
      flash[:alert] = "Mois invalide"
      redirect_to rooms_path and return
    end
  
    first_day_of_month = Date.new(@year, @month, 1)
    last_day_of_month = first_day_of_month.end_of_month
  
    @bookings = @room.bookings.where('start_date <= ? AND end_date >= ?', last_day_of_month, first_day_of_month)
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Salle non trouvée."
    redirect_to rooms_path
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
    @room = Room.find(params[:id])
    
    # Si les paramètres ne sont pas fournis, utilisez les valeurs par défaut (année et mois actuels)
    @year = params[:year].present? ? params[:year].to_i : Date.today.year
    @month = params[:month].present? ? params[:month].to_i : Date.today.month
    
    first_day_of_month = Date.new(@year, @month, 1)
    last_day_of_month = first_day_of_month.end_of_month
    
    @bookings = @room.bookings.where('start_date <= ? AND end_date >= ?', last_day_of_month, first_day_of_month)
  end
  

  # Créer une nouvelle salle
  def create
    @room = current_user.rooms.new(room_params)

    if @room.save
      attach_photos if params[:room][:main_photo].present? || params[:room][:additional_photos].present?
      redirect_to @room, notice: 'Salle ajoutée avec succès.'
    else
      render :new
    end
  end

  # Mettre à jour une salle
  def update
    if @room.update(room_params)
      attach_photos if params[:room][:main_photo].present? || params[:room][:additional_photos].present?
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
    @room = Room.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Salle non trouvée."
    redirect_to rooms_path
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

  def detailed_room_info
    {
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

  def attach_photos
    @room.main_photo.attach(params[:room][:main_photo]) if params[:room][:main_photo].present?
    @room.additional_photos.attach(params[:room][:additional_photos]) if params[:room][:additional_photos].present?
  end

