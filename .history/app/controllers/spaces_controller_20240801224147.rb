class SpacesController < ApplicationController
    before_action :set_space, only: [:show, :edit, :update, :destroy]


    def search
      query = params[:query]
      
      if query.present?
        # Vérifiez si la requête est un code postal (5 chiffres)
        if query.match?(/^\d{5}$/)
          @spaces = Space.where(department: query)
        else
          # Sinon, recherchez par nom de ville
          @spaces = Space.where("city ILIKE ?", "%#{query}%")
        end
      else
        @spaces = Space.none
      end
    
      render :search
    end

    private

    def set_space
      @space = Space.find(params[:id])
    end


  end