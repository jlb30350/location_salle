# app/helpers/seo_helper.rb
module SeoHelper
  def meta_title(title)
    content_for :meta_title, title
  end

  def meta_description(desc)
    content_for :meta_description, desc
  end
end

