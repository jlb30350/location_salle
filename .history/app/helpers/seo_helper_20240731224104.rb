# app/helpers/seo_helper.rb
module SeoHelper
    def meta_title(title)
      content_for :meta_title, title
    end
  
    def meta_description(desc)
      content_for :meta_description, desc
    end
  
    def canonical_link(url)
      content_for :canonical_link, url
    end
  
    def og_tags(og = {})
      og.each do |property, content|
        content_for :og_tags, tag(:meta, property: "og:#{property}", content: content)
      end
    end
  end
  
  # app/views/layouts/application.html.erb
  <head>
    <title><%= content_for?(:meta_title) ? yield(:meta_title) : "Location de salles" %></title>
    <meta name="description" content="<%= content_for?(:meta_description) ? yield(:meta_description) : "Trouvez la salle parfaite pour votre événement" %>">
    <%= yield(:canonical_link) if content_for?(:canonical_link) %>
    <%= yield(:og_tags) if content_for?(:og_tags) %>
    <meta name="robots" content="index, follow">
    <!-- Autres meta tags -->
  </head>
  
  # app/views/rooms/show.html.erb
  <% meta_title @room.name %>
  <% meta_description @room.description.truncate(160) %>
  <% canonical_link room_url(@room) %>
  <% og_tags({
    title: @room.name,
    description: @room.description.truncate(160),
    image: url_for(@room.photos.first),
    url: room_url(@room)
  }) %>
  
  <h1><%= @room.name %></h1>
  <!-- Reste du contenu -->