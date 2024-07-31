class SpacesController < ApplicationController
    before_action :set_space, only: [:show, :edit, :update, :destroy]


    def search
      @spaces = Space.near([params[:lat], params[:lng]], 50)  # Recherche dans un rayon de 50km
      render json: @spaces
    end

    private

    def set_space
      @space = Space.find(params[:id])
    end


  end