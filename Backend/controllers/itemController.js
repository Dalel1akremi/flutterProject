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
