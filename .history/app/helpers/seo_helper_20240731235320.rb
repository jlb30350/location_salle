# app/helpers/seo_helper.rb
module SeoHelper
    def meta_title
      content_for?(:meta_title) ? yield(:meta_title) : "Location des salles"
    end
  
    def meta_description
      content_for?(:meta_description) ? yield(:meta_description) : "Trouvez la salle parfaite pour votre événement"
    end
  
    def canonical_link
      yield(:canonical_link) if content_for?(:canonical_link)
    end
  end
  