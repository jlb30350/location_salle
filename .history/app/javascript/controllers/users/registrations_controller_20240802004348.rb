# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
    def destroy
      # Supprimez d'abord les salles si l'utilisateur est un bailleur
      if resource.bailleur?
        resource.rooms.destroy_all
      end
      
      # Puis supprimez l'utilisateur
      resource.destroy
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      set_flash_message! :notice, :destroyed
      yield resource if block_given?
      respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
    end
  end