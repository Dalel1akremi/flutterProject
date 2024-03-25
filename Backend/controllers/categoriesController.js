const Categories = require('../models/CategoriesModel');
const createCategorie = async (req, res) => {
  try {
    let { nom_cat, type_cat } = req.body;
    const {  id_rest } = req.query;
    nom_cat = nom_cat.charAt(0).toUpperCase() + nom_cat.slice(1).toLowerCase();
    const existingCategorie = await Categories.findOne({ nom_cat });

    if (existingCategorie) {
      return res.status(400).json({
        status: 400,
        message: 'Cette catégorie existe déjà'
      });
    }
    const newCategorie = new Categories({
      id_rest: id_rest,
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

