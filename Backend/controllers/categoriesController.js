const Categories = require('../models/categoriesModel');

const createCategorie = async (req, res) => {
  try {
    const { body, file } = req;
    let { nom_cat, id_rest } = body;
    const imageUrl = file ? `images/${file.filename}` : null;
    nom_cat = nom_cat.charAt(0).toUpperCase() + nom_cat.slice(1).toLowerCase();
    const existingCategorie = await Categories.findOne({ nom_cat, id_rest });

    if (existingCategorie) {
      return res.status(400).json({
        status: 400,
        message: 'Cette catégorie existe déjà'
      });
    }

   
    const newCategorie = new Categories({
      id_rest,
      nom_cat,
      image: imageUrl,
      isArchived: false,
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


const getCategories = async (req, res) => {
  try {
    const { id_rest } = req.query;
    const categories = await Categories.find(
      { id_rest: id_rest, 'isArchived': false }, 
      'nom_cat id_cat image isArchived'
    );
    res.status(200).json({
      status: 200,
      message: "Succès de récupération des catégories",
      data: categories
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: "Erreur lors de la récupération des catégories"
    });
  }
};

const getCategoriesAd = async (req, res) => {
  try {
    const { id_rest } = req.query;
    const categories = await Categories.find({ id_rest: id_rest }, 'nom_cat  id_cat ,image, isArchived');
    res.status(200).json({
      status: 200,
      message: "Succès de récupération des catégories",
      data: categories
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: "Erreur lors de la récupération des catégories"
    });
  }
};
const ArchivedCategorie = async (req, res) => {
  try {
    const { _id} = req.params;
    const { isArchived } = req.body;
   

    if (!_id) {
      return res.status(400).json({
        status: 400,
        message: "L'ID de l'élément à mettre à jour est manquant.",
      });
    }

    await Categories.findOneAndUpdate({ _id: _id }, { isArchived });

    res.status(200).json({
      status: 200,
      message: "L'élément a été mis à jour avec succès.",
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la mise à jour de l\'élément.',
    });
  }
};




const updateCategory = async (req, res) => {
  try {
    let { id_cat } = req.params;
    const { nom_cat } = req.body;
    id_cat = parseInt(id_cat);

    if (!id_cat || isNaN(id_cat) || !nom_cat) {
      return res.status(400).json({
        status: 400,
        message: "L'ID de la catégorie ou le nouveau nom de la catégorie est manquant ou invalide.",
      });
    }

    const category = await Categories.findOne({ id_cat });

    if (!category) {
      return res.status(404).json({
        status: 404,
        message: "Catégorie non trouvée.",
      });
    }

    category.nom_cat = nom_cat.charAt(0).toUpperCase() + nom_cat.slice(1).toLowerCase();
    await category.save();

    res.status(200).json({
      status: 200,
      message: "La catégorie a été mise à jour avec succès.",
      data: category,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: "Erreur lors de la mise à jour de la catégorie.",
      error: error.message,
    });
  }
};


module.exports = {
  createCategorie,
  getCategories,
  ArchivedCategorie,
  updateCategory,
  getCategoriesAd,
};


