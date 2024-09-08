class UsersController < ApplicationController
  before_action :authenticate_user!

  def switch_role
    if current_user.bailleur?
      current_user.update(role: 'loueur')
      flash[:notice] = "Vous êtes maintenant en mode loueur."
    else
      current_user.update(role: 'bailleur')
      flash[:notice] = "Vous êtes maintenant en mode bailleur."
    end
    redirect_to dashboard_path
  end
end
