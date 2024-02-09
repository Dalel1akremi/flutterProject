const Categories = require('../models/categoriesModel');
exports.createCategorie = async (req, res) => {
                    try {
                      const { nom_cat, type_cat } = req.body;
                      const existingCategorie = await Categories.findOne({ nom_cat });

                      if (existingCategorie) {
                        
                        res.json({
                          status: 400,
                          message: 'Ce menu existe déjà'
                        });
                        return;
                      }
                      const newCategorie = new Categories({
                        nom_cat,
                        type_cat,
                        
                      });
                  
                      const savedCategorie = await newCategorie.save();
    res.json({
      status: 200,
      message: 'Ma categorie a ete cree avec succees ',
      data: savedCategorie,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la creation de categorie',
      error: error.message,
    });
  }
};
                  
const sendResponse = (res, statusCode, message, data = null) => {
  res.status(statusCode).json({ message, data, status: statusCode });
};

exports.getCategories = async (req, res) => {
  try {
    // Récupération de toutes les catégories depuis la base de données
    const categories = await Categories.find({}, 'nom_cat type_cat id_cat');
    sendResponse(res, 200, "Succès de récupération des catégories", categories);
  } catch (error) {
    console.error(error);
    sendResponse(res, 500, "Erreur lors de la récupération des catégories");
  }
};

