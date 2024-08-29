class ApplicationController < ActionController::Base
  helper :seo
  
  after_action :store_location

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

  private

  def store_location
    # Stocker la dernière URL visitée dans la session si elle est navigable
    if request.get? && is_navigational_format? && !request.xhr?
      session[:user_return_to] = request.fullpath
    end
  end
end
