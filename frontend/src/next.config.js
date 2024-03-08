// next.config.js
module.exports = {
                    // Définir le répertoire personnalisé pour les pages
                    // En supposant que vos pages sont dans le dossier Pages
                    Pages: {
                      // Définir le dossier personnalisé pour les pages
                      // par rapport à la racine du projet
                      './Pages': {
                        // Inclure toutes les pages dans ce dossier
                        include: '*.tsx'
                      }
                    }
                  };
                  