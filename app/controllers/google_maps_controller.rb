# app/controllers/google_maps_controller.rb
class GoogleMapsController < ApplicationController
    def load_script
      @api_key = ENV['GOOGLE_MAPS_API_KEY']
      render layout: false
    end
  end