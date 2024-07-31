class SpacesController < ApplicationController
    def search
      @spaces = Space.near([params[:lat], params[:lng]], 50)  # Recherche dans un rayon de 50km
      render json: @spaces
    end



    
  end