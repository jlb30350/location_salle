# app/helpers/seo_helper.rb
module SeoHelper
  def meta_title(title)
    content_for(:meta_title, title)
  end

  def meta_description(description)
    content_for(:meta_description, description)
  end

  def og_tags(tags = {})
    content_for(:og_tags, tags.map { |key, value| tag.meta(property: "og:#{key}", content: value) }.join("\n").html_safe)
  end

  def canonical_link(url)
    tag.link(rel: 'canonical', href: url)
  end
end
