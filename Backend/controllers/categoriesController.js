const mongoose = require('mongoose');
const Categories = require('../models/categoriesModel');
const createCategorie = async (req, res) => {
  try {
    let { nom_cat, id_rest } = req.body; 
    nom_cat = nom_cat.charAt(0).toUpperCase() + nom_cat.slice(1).toLowerCase();
    const existingCategorie = await Categories.findOne({ nom_cat });

    if (existingCategorie) {
      return res.status(400).json({
        status: 400,
        message: 'Cette catégorie existe déjà'
      });
    }

   
    const newCategorie = new Categories({
      id_rest,
      nom_cat,
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
    const categories = await Categories.find({ id_rest: id_rest }, 'nom_cat  id_cat , isArchived');
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
    const { id_cat } = req.params;

    if (!id_cat) {
      return res.status(400).json({
        status: 400,
        message: "L'ID de l'élément à mettre à jour est manquant.",
      });
    }

    // Recherche du document par son ID
    const category = await Categories.findOne({ id_cat });

    if (!category) {
      return res.status(404).json({
        status: 404,
        message: "Catégorie non trouvée.",
      });
    }

    // Bascule de l'état de isArchived
    category.isArchived = !category.isArchived;
    await category.save();

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

    // Convertir id_cat en nombre
    id_cat = parseInt(id_cat);

    if (!id_cat || isNaN(id_cat) || !nom_cat) {
      return res.status(400).json({
        status: 400,
        message: "L'ID de la catégorie ou le nouveau nom de la catégorie est manquant ou invalide.",
      });
    }

    // Recherche de la catégorie par son ID
    const category = await Categories.findOne({ id_cat });

    if (!category) {
      return res.status(404).json({
        status: 404,
        message: "Catégorie non trouvée.",
      });
    }

    // Mettre à jour le nom de la catégorie
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
};


