const Categories = require('../models/categoriesModel');
exports.createCategorie = async (req, res) => {
                    try {
                      const { nom_cat, type_cat } = req.body;
                  
                      // Création d'une nouvelle catégorie
                      const nouvelleCategorie = new Categories({ nom_cat, type_cat });
                  
                      // Enregistrement de la catégorie dans la base de données
                      await nouvelleCategorie.save();
                  
                      res.status(201).json({ message: 'Catégorie créée avec succès' });
                    } catch (error) {
                      console.error(error);
                      res.status(500).json({ message: 'Erreur lors de la création de la catégorie' });
                    }
                  };
                  