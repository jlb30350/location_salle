# app/helpers/application_helper.rb
module ApplicationHelper
  def message_mode_utilisateur
    return "Vous n'êtes pas connecté." unless user_signed_in?

    role_message = if current_user.bailleur?
                     "Vous êtes connecté en tant que bailleur."
                   elsif current_user.loueur?
                     "Vous êtes connecté en tant que loueur."
                   else
                     "Votre rôle d'utilisateur n'est pas défini."
                   end

    "#{role_message} Votre adresse e-mail est #{current_user.email}."
  end
end
