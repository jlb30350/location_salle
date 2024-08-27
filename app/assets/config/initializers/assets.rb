# Version des assets, permet d'invalider le cache des fichiers compilés si besoin
Rails.application.config.assets.version = '1.0'

# Ajouter le chemin des modules Node.js pour permettre à Sprockets de trouver les fichiers d'assets
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Préciser les fichiers JS et CSS principaux à précompiler
Rails.application.config.assets.precompile += %w( application.js application.css )

# Préciser les fichiers d'image spécifiques à précompiler
Rails.application.config.assets.precompile += %w( default_image.png )

# Préciser les fichiers Lightbox à précompiler
Rails.application.config.assets.precompile += %w( lightbox/prev.png lightbox/next.png lightbox/loading.gif lightbox/close.png )

# Préciser le fichier CSS de Lightbox à précompiler
Rails.application.config.assets.precompile += %w( lightbox.css )
