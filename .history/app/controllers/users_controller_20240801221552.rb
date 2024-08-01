# app/controllers/users_controller.rb
class UsersController < ApplicationController
    def switch_role
      if current_user.client?
        current_user.update(role: :bailleur)
        redirect_to dashboard_path, notice: 'Vous êtes maintenant un bailleur.'
      elsif current_user.bailleur?
        current_user.update(role: :client)
        redirect_to dashboard_path, notice: 'Vous êtes maintenant un client.'
      end
    end
  end