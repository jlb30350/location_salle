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
  
  
  
 