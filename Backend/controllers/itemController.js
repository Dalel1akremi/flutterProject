const Item = require('../models/itemModel');

exports.createItem = async (req, res) => {
  try {
    const { body, file } = req;

    const {
      nom,
      type,
      prix,
      description,
      isArchived,
      quantite,
      max_quantite,
      is_Menu,
      is_Redirect,
      id_cat,
      id,
    } = body;
    const imageUrl = file ? `http://localhost:3000/images/${file.filename}` : null;

    // Validate data types
    const validatedPrix = parseFloat(prix);
    const validatedIsArchived = isArchived==='true';
    const validatedQuantite = parseInt(quantite);
    const validatedMaxQuantite = parseInt(max_quantite);
    const validatedIsMenu = is_Menu === 'true';
    const validatedIsRedirect=is_Redirect==='true';
  

    // Check if validation fails
    if (isNaN(validatedPrix)) {
      console.error('Invalid prix:', prix);
    }
    if (isNaN(validatedQuantite)) {
      console.error('Invalid quantite:', quantite);
    }
    if (isNaN(validatedMaxQuantite)) {
      console.error('Invalid max_quantite:', max_quantite);
    }

    if (isNaN(validatedPrix) || isNaN(validatedQuantite) || isNaN(validatedMaxQuantite)) {
      
      res.json({
        status: 400,
        message: 'Invalid data types in request body'
      });
      return;
    }

    const existingItem = await Item.findOne({ nom});

    if (existingItem) {
      
      res.json({
        status: 400,
        message: 'Ce Item existe déjà'
      });
      return;
    }
    console.log('New Item Data:', {
      nom,
      type,
      prix: validatedPrix,
      description,
      isArchived: validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
      is_Redirect:validatedIsRedirect,
      id_cat,
      id,  // Log the id field
    });
    const newItem = new Item({
      nom,
      type,
      prix: validatedPrix,
      description,
      isArchived: validatedIsArchived,
      quantite: validatedQuantite,
      max_quantite: validatedMaxQuantite,
      is_Menu: validatedIsMenu,
      is_Redirect:validatedIsRedirect,
      id_cat,
      id,
      image: imageUrl,
    });

    const savedItem= await Item.save();
    res.json({
      status: 200,
      message: 'Item crée avec succée ',
      data: savedItem,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      status: 500,
      message: 'Erreur lors de la création de Item ',
      error: error.message,
    });
  }
};



const sendResponse = (res, statusCode, message, data = null, errorMessage = null) => {
  res.status(statusCode).json({ status: statusCode, message, data, error: errorMessage });
};

exports.getItem = async (req, res) => {
  try {
    const { id_cat } = req.query;

    // Fetch menus based on the provided type
    const Items = await Item.find({ id_cat });

    if (Item.length === 0) {
      sendResponse(res, 404, 'Aucun Item trouvé pour ce type');
    } else {
      sendResponse(res, 200, 'Item récupérés avec succès', Items);
    }
  } catch (error) {
    console.error(error);
    sendResponse(res, 500, 'Erreur lors de la récupération des Item', null, error.message);
  }
};