class ApplicationController < ActionController::Base
  helper :seo
  
  after_action :store_location

  # Ajout de cette ligne pour que Devise permette les nouveaux champs
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    # Vérifie s'il y a une recherche en cours dans la session
    if session[:search_query].present?
      # Redirige l'utilisateur vers la recherche effectuée après connexion
      search_rooms_path(query: session[:search_query])
    else
      super
    end
  end

  def test_bootstrap
    # Vous pouvez ajouter une logique ici si nécessaire
    render 'layouts/test_bootstrap'
  end

  def simple_test
    render plain: "Ceci est un simple test."
  end

  protected

  # Permettre les paramètres supplémentaires pour Devise (comme first_name, last_name, phone)
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :role])
  end

  private

  def store_location
    # Stocker la dernière URL visitée dans la session si elle est navigable
    if request.get? && is_navigational_format? && !request.xhr?
      session[:user_return_to] = request.fullpath
    end
  end
end
