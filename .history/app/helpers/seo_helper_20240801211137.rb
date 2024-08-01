# app/helpers/seo_helper.rb
module SeoHelper
  def meta_title(title)
    content_for :meta_title, title
  end

  def meta_description(desc)
    content_for :meta_description, desc
  end
end

# app/views/layouts/application.html.erb
<head>
  <title><%= content_for?(:meta_title) ? yield(:meta_title) : "Location de salles" %></title>
  <meta name="description" content="<%= content_for?(:meta_description) ? yield(:meta_description) : "Trouvez la salle parfaite pour votre événement" %>">
  <!-- Autres meta tags -->
</head>