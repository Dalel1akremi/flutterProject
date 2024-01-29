// controllers/itemController.js

const Items =require( '../models/itemsModel');

const sendResponse = (res, status, message, data = null, error = null) => {
  res.status(status).json({ status, message, data, error });
};

exports.createItem = async (req, res) => {
  try {
    const {
      nom,
      type,
      prix,
      description,
      isArchived,
      image,
      quantite,
      max_quantite,
      is_Menu,
      nom_cat,
      id,
    } = req.body;

    const newItem = new Items({
      nom,
      type,
      prix,
      description,
      isArchived,
      image,
      quantite,
      max_quantite,
      is_Menu,
      nom_cat,
      id,
    });

    await newItem.save();
    sendResponse(res, 201, 'Item créé avec succès', newItem);
  } catch (error) {
    console.error(error);
    sendResponse(res, 500, 'Erreur lors de la création de l\'item', null, error.message);
  }
};
exports.getItem = async (req, res) => {
                    try {
                      // Récupération de toutes les catégories depuis la base de données
                      const item = await Items.find({}, ' nom type prix description isArchived image quantite max_quantite is_Menu nom_cat id');
                      res.status(200).json({message:"succée de recuperation des items",data:item ,status:res.statusCode});
                    } catch (error) {
                      console.error(error);
                      res.status(500).json({ message: 'Erreur lors de la récupération des items' });
                    }
                  };