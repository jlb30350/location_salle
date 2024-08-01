# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
    def destroy
      email = resource.email
      # ... le reste du code de destruction ...
      UserMailer.account_deleted_email(email).deliver_later
    end
  end