# config/initializers/wicked_pdf.rb
WickedPdf.config = {
  # Configuration pour wkhtmltopdf
  exe_path: Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf')
}
