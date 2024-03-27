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

    // Vérifier le type de id_rest et le convertir en tableau si nécessaire
    let idRestArray = [];
    if (typeof id_rest === 'string') {
      // Si id_rest est une chaîne de caractères, la diviser en un tableau d'entiers
      idRestArray = id_rest.split(',').map(id => parseInt(id.trim()));
    } else if (Array.isArray(id_rest)) {
      // Si id_rest est déjà un tableau, l'utiliser directement
      idRestArray = id_rest.map(id => parseInt(id));
    } else {
      // Si id_rest n'est ni une chaîne ni un tableau, laisser idRestArray vide
      idRestArray = [];
    }

    // Créer une nouvelle catégorie avec les références id_rest
    const newCategorie = new Categories({
      id_rest: idRestArray,
      nom_cat,
      type_cat
    });

    // Enregistrer la nouvelle catégorie
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
    const categories = await Categories.find({ id_rest: id_rest }, 'nom_cat type_cat id_cat');
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

module.exports = {
  createCategorie,
  getCategories,
}

