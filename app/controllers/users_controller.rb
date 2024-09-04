class UsersController < ApplicationController
  def switch_role
    if current_user.loueur?
      current_user.update(role: 'bailleur')
      redirect_to dashboard_path, notice: "Vous êtes maintenant en mode bailleur. Vous pouvez maintenant gérer vos propres salles."
    elsif current_user.bailleur?
      current_user.update(role: 'loueur')
      redirect_to dashboard_path, notice: "Vous êtes maintenant en mode loueur. Vous pouvez maintenant réserver des salles."
    else
      redirect_to dashboard_path, alert: "Erreur de changement de rôle."
    end
  end
end
