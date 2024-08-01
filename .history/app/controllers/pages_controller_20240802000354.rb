# app/controllers/pages_controller.rb
class PagesController < ApplicationController
    def home
      # Logique pour la page d'accueil
    end
  
    def about
      # Informations sur votre service
    end
  
    def contact
      # Page de contact
    end
  
    def faq
      # Foire aux questions
    end
  
    def terms
      # Conditions d'utilisation
    end
  
    def privacy
      # Politique de confidentialité
    end
  
    def search
      query = params[:query].to_s.strip.downcase
      
      if query.present?
        if query.match?(/^\d{5}$/)
          @spaces = Space.where(department: query)
        else
          @spaces = Space.where("LOWER(city) LIKE ?", "%#{query}%")
        end
  
        if @spaces.empty?
          @spaces = Space.where("LOWER(city) LIKE ? OR department LIKE ? OR LOWER(address) LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%")
        end
  
        if @spaces.empty? && defined?(Geocoder)
          results = Geocoder.search(query)
          if results.any?
            coordinates = results.first.coordinates
            @spaces = Space.near(coordinates, 50)
          end
        end
      else
        @spaces = Space.none
      end
  
      render 'spaces/index'  # Ou créez une vue spécifique pour les résultats de recherche
    end
  end