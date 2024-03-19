const Categories = require('../models/categoriesModel');
exports.createCategorie = async (req, res) => {
  try {
    let { nom_cat, type_cat } = req.body;

    nom_cat = nom_cat.charAt(0).toUpperCase() + nom_cat.slice(1).toLowerCase();
    const existingCategorie = await Categories.findOne({ nom_cat });

    if (existingCategorie) {
      return res.status(400).json({
        status: 400,
        message: 'Cette catégorie existe déjà'
      });
    }
    const newCategorie = new Categories({
      nom_cat,
      type_cat
    });
    const savedCategorie = await newCategorie.save();

    return res.status(200).json({
      status: 200,
      message: 'La catégorie a été créée avec succès',
      data: savedCategorie,
    });
  } catch (error) {
    console.error(error);
    return res.status(500).json({
      status: 500,
      message: 'Erreur lors de la création de la catégorie',
      error: error.message,
    });
  }
};

                  
const sendResponse = (res, statusCode, message, data = null) => {
  res.status(statusCode).json({ message, data, status: statusCode });
};

exports.getCategories = async (req, res) => {
  try {
    const categories = await Categories.find({}, 'nom_cat type_cat id_cat');
    sendResponse(res, 200, "Succès de récupération des catégories", categories);
  } catch (error) {
    console.error(error);
    sendResponse(res, 500, "Erreur lors de la récupération des catégories");
  }
};

