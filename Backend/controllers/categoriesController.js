const Categories = require('../models/categoriesModel');
const createCategorie = async (req, res) => {
  try {
    let { nom_cat, type_cat, id_rest } = req.body; 
    nom_cat = nom_cat.charAt(0).toUpperCase() + nom_cat.slice(1).toLowerCase();
    const existingCategorie = await Categories.findOne({ nom_cat });

    if (existingCategorie) {
      return res.status(400).json({
        status: 400,
        message: 'Cette catégorie existe déjà'
      });
    }

    let idRestArray;
    if (typeof id_rest === 'string') {
      idRestArray = id_rest.split(',').map(id => parseInt(id.trim()));
    } else if (Array.isArray(id_rest)) {
      idRestArray = id_rest.map(id => parseInt(id));
    } else {
      idRestArray = [];
    }

    // Créez une nouvelle catégorie pour chaque id_rest
    const savedCategories = await Promise.all(idRestArray.map(async (restId) => {
      const newCategorie = new Categories({
        id_rest: restId, // Utilisez l'ID de chaque restaurant
        nom_cat,
        type_cat
      });
      return newCategorie.save();
    }));

    return res.status(200).json({
      status: 200,
      message: 'Les catégories ont été créées avec succès',
      data: savedCategories,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      status: 500,
      message: 'Erreur lors de la création des catégories',
      error: error.message,
    });
  }
};

const getCategories = async (req, res) => {
  try {
    const { id_rest } = req.query;
        const categories = await Categories.find({ id_rest: id_rest }, 'nom_cat type_cat id_cat');
    sendResponse(res, 200, "Succès de récupération des catégories", categories);
  } catch (error) {
    console.error(error);
    sendResponse(res, 500, "Erreur lors de la récupération des catégories");
  }
};
module.exports = {
  createCategorie,
  getCategories,
}

