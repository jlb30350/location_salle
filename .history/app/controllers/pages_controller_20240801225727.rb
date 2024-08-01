class SpacesController < ApplicationController
  before_action :set_space, only: %i[show edit update destroy]

  def index
    @spaces = current_user.spaces
  end

  def show
    @booking = @space.bookings.new
  end

  def new
    @space = Space.new
  end

  def create
    @space = current_user.spaces.new(space_params)
    if @space.save
      redirect_to @space, notice: 'Espace créé avec succès.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @space.update(space_params)
      redirect_to @space, notice: 'Espace mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    @space.destroy
    redirect_to spaces_url, notice: 'Espace supprimé avec succès.'
  end

  def search_location
    address = params[:query] + ", France"
    results = Geocoder.search(address)
    if results.any?
      render json: { 
        lat: results.first.latitude, 
        lng: results.first.longitude 
      }
    else
      render json: { error: "Localisation non trouvée" }, status: :not_found
    end
  end

  def search
    query = params[:query].to_s.strip.downcase
    
    if params[:lat].present? && params[:lng].present?
      @spaces = Space.near([params[:lat], params[:lng]], 50)
    elsif query.present?
      if query.match?(/^\d{5}$/)
        @spaces = Space.where(department: query)
      else
        @spaces = Space.where("LOWER(city) LIKE ?", "%#{query}%")
      end

      if @spaces.empty?
        @spaces = Space.where("LOWER(city) LIKE ? OR department LIKE ? OR LOWER(address) LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")
      end

      if @spaces.empty?
        results = Geocoder.search(query)
        if results.any?
          coordinates = results.first.coordinates
          @spaces = Space.near(coordinates, 50)
        end
      end
    else
      @spaces = Space.none
    end

    render json: @spaces
  end

  private

  def space_params
    params.require(:space).permit(:title, :description, :address, :city, :department, :email, :phone, :price, :space_type, :location_type, :tables_count, :chairs_count, :floor, :has_elevator, :has_air_conditioning, :has_water_fountain, :has_parking, :has_wifi, :has_kitchen, :has_sound_system, :wheelchair_accessible, :capacity, photos: [])
  end

  def set_space
    @space = Space.find(params[:id])
  end
end